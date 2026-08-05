import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'fcm_background_handler.dart';
import '../../../config.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  String? _jwtToken;
  void Function(Map<String, dynamic>? data)? _onNotificationTap;
  void Function(String? title, String? body)? _onMessageReceived;
  Dio? _customDio;

  @visibleForTesting
  void setDioForTesting(Dio dio) {
    _customDio = dio;
  }

  Dio get _dio => _customDio ?? Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  void setJwtToken(String? token) {
    _jwtToken = token;
  }

  void setOnNotificationTap(void Function(Map<String, dynamic>? data)? callback) {
    _onNotificationTap = callback;
  }

  void setOnMessageReceived(void Function(String? title, String? body)? callback) {
    _onMessageReceived = callback;
  }

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();

    await _setupNotificationChannel();

    await requestPermission();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefreshed);
  }

  Future<void> _setupNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTap?.call({'id_alert': response.payload});
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<NotificationSettings> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('FCM Permission status: ${settings.authorizationStatus}',
        name: 'FCMService');

    return settings;
  }

  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      log('FCM Token: $token', name: 'FCMService');
      return token;
    } catch (e) {
      log('Error getting FCM token: $e', name: 'FCMService');
      return null;
    }
  }

  bool get _hasValidJwt => _jwtToken != null && _jwtToken!.split('.').length == 3;

  bool _isValidJwt(String token) => token.split('.').length == 3;

  Future<void> _onTokenRefreshed(String? newToken) async {
    log('FCM Token refreshed: $newToken', name: 'FCMService');
    if (newToken != null && _hasValidJwt) {
      await registerTokenToServer(newToken, _jwtToken!);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received foreground message: ${message.notification?.title}',
        name: 'FCMService');

    _onMessageReceived?.call(
      message.notification?.title,
      message.notification?.body,
    );

    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription:
          'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: message.data['id_alert'],
    );
  }

  Future<bool> registerTokenToServer(String? token, String jwtToken,
      {int maxRetries = 3}) async {
    if (token == null || token.isEmpty) return false;
    if (!_isValidJwt(jwtToken)) return false;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _dio.post(
          '/api/v1/alert/fcm-token',
          options: Options(
            headers: {'Authorization': 'Bearer $jwtToken'},
          ),
          data: {'fcm_token': token},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          log('FCM Token registered to server successfully',
              name: 'FCMService');
          return true;
        }

        log('FCM Token registration failed: ${response.statusCode}',
            name: 'FCMService');
        return false;
      } catch (e) {
        log('Error registering FCM token (attempt $attempt/$maxRetries): $e',
            name: 'FCMService');
        if (attempt == maxRetries) return false;
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    return false;
  }

  Future<bool> registerCurrentToken() async {
    final token = await getToken();
    if (token == null || _jwtToken == null) return false;
    return registerTokenToServer(token, _jwtToken!);
  }

  void onTokenRefresh(void Function(String?) onChanged) {
    _firebaseMessaging.onTokenRefresh.listen(onChanged);
  }

  Future<void> handleInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('Notification tapped: ${message.data}', name: 'FCMService');
  }

  Future<bool> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription:
            'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        999,
        'Test Notifikasi',
        'Ini notifikasi lokal test',
        platformDetails,
        payload: 'test-001',
      );
      return true;
    } catch (e) {
      log('Error showing test notification: $e', name: 'FCMService');
      return false;
    }
  }

  Future<NotificationSettings> getPermissionSettings() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Background message handler (harus top-level function)
/// Dipanggil ketika notifikasi diterima saat app berada di background atau killed state
@pragma('dart:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}', name: 'FCMService');
  log('Title: ${message.notification?.title}', name: 'FCMService');
  log('Body: ${message.notification?.body}', name: 'FCMService');
  log('Data: ${message.data}', name: 'FCMService');
  // Firebase akan otomatis menampilkan notifikasi di background
  // Tidak perlu menampilkan notifikasi manual di sini
}



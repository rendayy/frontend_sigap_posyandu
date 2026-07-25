import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class _TestData {
  final String id;
  final String value;
  const _TestData({required this.id, required this.value});

  Map<String, dynamic> toJson() => {'id': id, 'value': value};
  factory _TestData.fromJson(Map<String, dynamic> j) =>
      _TestData(id: j['id'] as String, value: j['value'] as String);
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  group('ModulePageHelper', () {
    test('initial state', () {
      final h = ModulePageHelper<_TestData>();
      expect(h.data, isNull);
      expect(h.isLoading, isTrue);
      expect(h.isFromCache, isFalse);
      expect(h.isReconnecting, isFalse);
      expect(h.error, isNull);
      expect(h.showSkeleton, isTrue);
    });

    test('startLoad resets state and sets loading', () {
      final h = ModulePageHelper<_TestData>();
      h.data = _TestData(id: '1', value: 'old');
      h.error = 'previous error';
      h.isFromCache = true;

      h.startLoad();

      expect(h.isLoading, isTrue);
      expect(h.isReconnecting, isTrue);
      expect(h.error, isNull);
      expect(h.data?.value, 'old');
      expect(h.showSkeleton, isFalse);
    });

    test('onSuccess clears cache flag and stops loading', () {
      final h = ModulePageHelper<_TestData>();
      h.startLoad();
      h.onSuccess(_TestData(id: '2', value: 'new'));

      expect(h.isLoading, isFalse);
      expect(h.isFromCache, isFalse);
      expect(h.isReconnecting, isFalse);
      expect(h.data?.value, 'new');
      expect(h.showSkeleton, isFalse);
    });

    test('onCacheLoaded sets cache flag and stops loading', () {
      final h = ModulePageHelper<_TestData>();
      h.startLoad();
      h.onCacheLoaded(_TestData(id: '3', value: 'cached'));

      expect(h.isLoading, isFalse);
      expect(h.isFromCache, isTrue);
      expect(h.isReconnecting, isFalse);
      expect(h.data?.value, 'cached');
    });

    test('onError sets error message and stops loading', () {
      final h = ModulePageHelper<_TestData>();
      h.startLoad();
      h.onError('Terjadi error');

      expect(h.isLoading, isFalse);
      expect(h.error, 'Terjadi error');
      expect(h.isReconnecting, isFalse);
    });

    test('showSkeleton true only when loading and no data', () {
      final h = ModulePageHelper<_TestData>();
      expect(h.showSkeleton, isTrue);

      h.data = _TestData(id: '1', value: 'x');
      h.isLoading = true;
      expect(h.showSkeleton, isFalse);

      h.isLoading = false;
      expect(h.showSkeleton, isFalse);
    });
  });

  group('buildModuleError', () {
    testWidgets('renders error message and retry button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: buildModuleError('Gagal memuat data', () {}),
        ),
      ));

      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button calls onRetry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: buildModuleError('Error', () => retried = true),
        ),
      ));

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });
  });

  group('loadModuleData', () {
    testWidgets('success path: fetches data, saves cache, calls onSuccess',
        (tester) async {
      final helper = ModulePageHelper<_TestData>();
      final cache = CacheManager<_TestData>(
        prefix: 'test_success',
        fromJson: _TestData.fromJson,
        toJson: (d) => d.toJson(),
      );
      bool stateUpdated = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () async {
                await loadModuleData(
                  helper: helper,
                  getModuleId: () async => 'mod-1',
                  fetchFromApi: (id) async =>
                      _TestData(id: id, value: 'fetched'),
                  cacheManager: cache,
                  setState: () => stateUpdated = true,
                  context: ctx,
                );
              },
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(helper.data?.value, 'fetched');
      expect(helper.isLoading, isFalse);
      expect(helper.isFromCache, isFalse);
      expect(stateUpdated, isTrue);

      final cached = await cache.load('mod-1');
      expect(cached?.value, 'fetched');
    });

    testWidgets('error with cache fallback: shows snackbar and cached data',
        (tester) async {
      final helper = ModulePageHelper<_TestData>();
      final cache = CacheManager<_TestData>(
        prefix: 'test_cache_fb',
        fromJson: _TestData.fromJson,
        toJson: (d) => d.toJson(),
      );
      await cache.save('mod-2', _TestData(id: 'mod-2', value: 'cached'));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () async {
                await loadModuleData(
                  helper: helper,
                  getModuleId: () async => 'mod-2',
                  fetchFromApi: (id) async => throw NetworkException(),
                  cacheManager: cache,
                  setState: () {},
                  context: ctx,
                );
              },
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(helper.data?.value, 'cached');
      expect(helper.isFromCache, isTrue);
      expect(helper.isLoading, isFalse);
    });

    testWidgets('error without cache: shows error state',
        (tester) async {
      final helper = ModulePageHelper<_TestData>();
      final cache = CacheManager<_TestData>(
        prefix: 'test_no_cache',
        fromJson: _TestData.fromJson,
        toJson: (d) => d.toJson(),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () async {
                await loadModuleData(
                  helper: helper,
                  getModuleId: () async => 'mod-3',
                  fetchFromApi: (id) async => throw NetworkException(),
                  cacheManager: cache,
                  setState: () {},
                  context: ctx,
                );
              },
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(helper.error, contains('Tidak dapat terhubung ke server'));
      expect(helper.isLoading, isFalse);
    });
  });
}

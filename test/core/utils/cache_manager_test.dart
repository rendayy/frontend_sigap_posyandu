import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';

class _TestModel {
  final String id;
  final String name;

  const _TestModel({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  static _TestModel fromJson(Map<String, dynamic> json) {
    return _TestModel(id: json['id'] as String, name: json['name'] as String);
  }
}

void main() {
  late CacheManager<_TestModel> cache;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = CacheManager<_TestModel>(
      prefix: 'test',
      fromJson: _TestModel.fromJson,
      toJson: (d) => d.toJson(),
    );
  });

  group('CacheManager', () {
    test('save and load', () async {
      await cache.save('123', const _TestModel(id: '123', name: 'Test'));
      final loaded = await cache.load('123');
      expect(loaded, isNotNull);
      expect(loaded!.id, '123');
      expect(loaded.name, 'Test');
    });

    test('load returns null for non-existent key', () async {
      final loaded = await cache.load('nonexistent');
      expect(loaded, isNull);
    });

    test('has returns true after save', () async {
      await cache.save('456', const _TestModel(id: '456', name: 'Another'));
      expect(await cache.has('456'), isTrue);
    });

    test('has returns false for non-existent key', () async {
      expect(await cache.has('nonexistent'), isFalse);
    });

    test('clear removes data', () async {
      await cache.save('789', const _TestModel(id: '789', name: 'ToDelete'));
      await cache.clear('789');
      expect(await cache.has('789'), isFalse);
      expect(await cache.load('789'), isNull);
    });

    test('save overwrites existing data', () async {
      await cache.save('1', const _TestModel(id: '1', name: 'First'));
      await cache.save('1', const _TestModel(id: '1', name: 'Second'));
      final loaded = await cache.load('1');
      expect(loaded!.name, 'Second');
    });

    test('different prefixes do not conflict', () async {
      final cacheA = CacheManager<_TestModel>(
        prefix: 'prefix_a',
        fromJson: _TestModel.fromJson,
        toJson: (d) => d.toJson(),
      );
      final cacheB = CacheManager<_TestModel>(
        prefix: 'prefix_b',
        fromJson: _TestModel.fromJson,
        toJson: (d) => d.toJson(),
      );

      await cacheA.save('1', const _TestModel(id: '1', name: 'From A'));
      await cacheB.save('1', const _TestModel(id: '1', name: 'From B'));

      expect((await cacheA.load('1'))!.name, 'From A');
      expect((await cacheB.load('1'))!.name, 'From B');
    });
  });
}

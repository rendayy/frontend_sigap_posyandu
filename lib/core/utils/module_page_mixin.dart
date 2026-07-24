import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class ModulePageHelper<T> {
  T? data;
  bool isLoading = true;
  bool isFromCache = false;
  bool isReconnecting = false;
  String? error;
  DateTime? lastFetchTime;

  void startLoad() {
    isLoading = true;
    isReconnecting = isFromCache;
    error = null;
  }

  void onSuccess(T? fetched) {
    data = fetched;
    lastFetchTime = DateTime.now();
    isFromCache = false;
    isReconnecting = false;
    isLoading = false;
  }

  void onCacheLoaded(T cached) {
    data = cached;
    isFromCache = true;
    isReconnecting = false;
    isLoading = false;
  }

  void onError(String msg) {
    error = msg;
    isReconnecting = false;
    isLoading = false;
  }

  bool get showSkeleton => isLoading && data == null;

  bool isStale(Duration threshold) {
    if (lastFetchTime == null) return true;
    return DateTime.now().difference(lastFetchTime!) > threshold;
  }
}

Future<void> loadModuleData<T>({
  required ModulePageHelper<T> helper,
  required Future<String?> Function() getModuleId,
  required Future<T?> Function(String id) fetchFromApi,
  required CacheManager<T> cacheManager,
  required VoidCallback setState,
  required BuildContext context,
  String? moduleId,
  Duration? staleAfter,
}) async {
  if (staleAfter != null && helper.data != null && !helper.isStale(staleAfter)) {
    return;
  }

  final isSilent = staleAfter != null && helper.data != null;

  if (!isSilent) {
    helper.startLoad();
    setState();
  }

  try {
    moduleId ??= await getModuleId();
    if (moduleId == null || moduleId.isEmpty) {
      throw Exception('ID tidak ditemukan');
    }

    final fetched = await fetchFromApi(moduleId);
    if (fetched != null) {
      await cacheManager.save(moduleId, fetched);
    }

    helper.onSuccess(fetched);
    setState();
  } catch (e) {
    if (isSessionExpired(e)) {
      if (moduleId != null) await cacheManager.clear(moduleId);
      await AuthService().logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    if (isSilent) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    moduleId ??= await getModuleId();
    final cached = moduleId != null ? await cacheManager.load(moduleId) : null;

    if (cached != null) {
      helper.onCacheLoaded(cached);
      setState();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      helper.onError(friendlyError(e));
      setState();
    }
  }
}

Widget buildModuleError(String message, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF2B4E)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

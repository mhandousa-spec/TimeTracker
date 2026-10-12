// ******************* FILE INFO *******************
// File Name: service_lookup_cache
// Description: Memoises the async lookups used by the request service cards
//              (provider name / job title, service data, owning department).
//              Without this, every rebuild — resize, theme change, bloc emit —
//              creates a brand new Future and the cards flash "..." forever.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

abstract class ServiceLookupCache {
  static final Map<String, Future<Map<String, dynamic>?>> _providers = {};
  static final Map<String, Future<Map<String, dynamic>>> _cardData = {};

  /// Returns the in-flight/completed provider lookup for [key], starting it
  /// with [loader] only the first time.
  static Future<Map<String, dynamic>?> provider(
    String key,
    Future<Map<String, dynamic>?> Function() loader,
  ) {
    final existing = _providers[key];
    if (existing != null) return existing;

    final future = loader();
    _providers[key] = future;
    // Don't cache failures — let the next build retry.
    future.catchError((Object e) {
      _providers.remove(key);
      throw e;
    });
    return future;
  }

  /// Same idea for the card's combined service-data + department lookup.
  static Future<Map<String, dynamic>> cardData(
    String key,
    Future<Map<String, dynamic>> Function() loader,
  ) {
    final existing = _cardData[key];
    if (existing != null) return existing;

    final future = loader();
    _cardData[key] = future;
    future.catchError((Object e) {
      _cardData.remove(key);
      throw e;
    });
    return future;
  }

  /// Call after a pull-to-refresh / data mutation so the cards refetch.
  static void clear() {
    _providers.clear();
    _cardData.clear();
  }

  static void evict(String key) {
    _providers.remove(key);
    _cardData.remove(key);
  }
}

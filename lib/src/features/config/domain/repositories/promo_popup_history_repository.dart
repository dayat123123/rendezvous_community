abstract interface class PromoPopupHistoryRepository {
  Future<Map<String, DateTime>> load(String userId);

  Future<void> save(String userId, Map<String, DateTime> shown);
}

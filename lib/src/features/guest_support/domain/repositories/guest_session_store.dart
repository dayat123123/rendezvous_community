import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';

abstract interface class CommunityGuestSessionStore {
  bool get persistent;

  Future<GuestSupportToken?> read();

  Future<void> write(GuestSupportToken token);

  Future<void> clear();
}

class MemoryGuestSessionStore implements CommunityGuestSessionStore {
  GuestSupportToken? _token;

  @override
  bool get persistent => false;

  @override
  Future<GuestSupportToken?> read() async => _token;

  @override
  Future<void> write(GuestSupportToken token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:rendezvous_community/src/app/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/network/anonymous_rpc.dart';
import 'package:rendezvous_community/src/features/guest_support/data/repositories/guest_support_repository_impl.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/repositories/guest_session_store.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/repositories/guest_support_repository.dart';

abstract interface class CommunityGuestSupportDependencies {
  GuestSupportRepository get guestSupport;

  CommunityGuestSessionStore get guestSessions;
}

class CommunityGuestSupportClient implements CommunityGuestSupportDependencies {
  CommunityGuestSupportClient({required this.guestSupport, CommunityGuestSessionStore? sessions})
    : guestSessions = sessions ?? MemoryGuestSessionStore();

  factory CommunityGuestSupportClient.anonymous({
    required String supabaseUrl,
    required String anonKey,
    http.Client? httpClient,
    CommunityGuestSessionStore? sessions,
  }) => CommunityGuestSupportClient(
    guestSupport: GuestSupportRepositoryImpl(
      AnonymousRpc(supabaseUrl: supabaseUrl, anonKey: anonKey, httpClient: httpClient).inSchema('cs_api'),
    ),
    sessions: sessions,
  );

  @override
  final GuestSupportRepository guestSupport;

  @override
  final CommunityGuestSessionStore guestSessions;
}

class CommunityGuestSupportScope extends InheritedWidget {
  const CommunityGuestSupportScope({super.key, required this.dependencies, required super.child});

  final CommunityGuestSupportDependencies dependencies;

  static CommunityGuestSupportDependencies of(BuildContext context) =>
      maybeOf(context) ??
      (throw StateError(
        'No CommunityGuestSupportScope found and RendezvousCommunity is not initialized; '
        'wrap the login page in CommunityGuestSupportScope(dependencies: CommunityGuestSupportClient.anonymous(...))',
      ));

  static CommunityGuestSupportDependencies? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityGuestSupportScope>()?.dependencies ??
      (RendezvousCommunity.isInitialized ? RendezvousCommunity.instance : null);

  @override
  bool updateShouldNotify(CommunityGuestSupportScope oldWidget) => !identical(dependencies, oldWidget.dependencies);
}

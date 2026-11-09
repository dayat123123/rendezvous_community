import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_guest_support_scope.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/cubit/guest_support_cubit.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/guest_support_texts.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/widgets/guest_support_chat_view.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/widgets/guest_support_form_view.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityGuestSupport extends StatelessWidget {
  const CommunityGuestSupport({super.key, this.pollInterval = const Duration(seconds: 4)});

  final Duration pollInterval;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityGuestSupportScope.of(context);
    final language = Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'id';
    return BlocProvider(
      create: (_) => GuestSupportCubit(
        repository: deps.guestSupport,
        store: deps.guestSessions,
        language: language,
        pollInterval: pollInterval,
      )..load(),
      child: _GuestSupportView(persistent: deps.guestSessions.persistent),
    );
  }
}

class _GuestSupportView extends StatefulWidget {
  const _GuestSupportView({required this.persistent});

  final bool persistent;

  @override
  State<_GuestSupportView> createState() => _GuestSupportViewState();
}

class _GuestSupportViewState extends State<_GuestSupportView> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<GuestSupportCubit>().setVisible(true),
      onHide: () => context.read<GuestSupportCubit>().setVisible(false),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocListener<GuestSupportCubit, GuestSupportState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId && b.actionError != null,
      listener: (context, state) =>
          showCommunityMessage(context, guestErrorText(l10n, state.actionError!, sending: state.ticket != null)),
      child: BlocBuilder<GuestSupportCubit, GuestSupportState>(
        buildWhen: (a, b) => a.phase != b.phase || a.error != b.error,
        builder: (context, state) {
          final cubit = context.read<GuestSupportCubit>();
          return switch (state.phase) {
            GuestSupportPhase.loading => const CommunityLoadingView(),
            GuestSupportPhase.failure => CommunityErrorView(error: state.error!, onRetry: cubit.load),
            GuestSupportPhase.disabled => CommunityEmptyView(
              icon: Icons.support_agent,
              message: l10n.guestSupportDisabled,
              action: TextButton(onPressed: cubit.load, child: Text(l10n.retry)),
            ),
            GuestSupportPhase.form => const GuestSupportFormView(),
            GuestSupportPhase.chat || GuestSupportPhase.ended => GuestSupportChatView(persistent: widget.persistent),
          };
        },
      ),
    );
  }
}

class CommunityGuestSupportPage extends StatelessWidget {
  const CommunityGuestSupportPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.communityL10n.guestSupportTitle)),
    body: const SafeArea(top: false, child: CommunityGuestSupport()),
  );
}

Future<void> openCommunityGuestSupport(BuildContext context) {
  final deps = CommunityGuestSupportScope.of(context);
  final carry = carryCommunityBuilders(context);
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => carry(CommunityGuestSupportScope(dependencies: deps, child: const CommunityGuestSupportPage())),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/cubit/guest_support_cubit.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/widgets/guest_support_chat_view.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/widgets/guest_support_form_view.dart';

import '../../test/support/guest_fakes.dart';
import 'screenshot_harness.dart';

class _ReadyGuestCubit extends GuestSupportCubit {
  _ReadyGuestCubit(GuestSupportState state)
    : super(repository: FakeGuestSupportRepository(), store: MemoryGuestSessionStore()) {
    emit(state);
  }
}

final _token = GuestSupportToken(token: 'scene-token', expiresAt: DateTime(2026, 11, 10, 9, 12));

List<ChatMessage> _messages() => [
  guestMessage('m-1', 'Saya lupa PIN setelah ganti HP. Login ID saya BUDI01.'),
  guestMessage(
    'm-2',
    'Nadia (CS07) menangani pengaduan Anda.',
    role: SenderRole.system,
    kind: MessageKind.system,
    minute: 3,
    payload: const {'code': 'ticket_claimed'},
  ),
  guestMessage(
    'm-3',
    'Halo Pak Budi, link reset PIN sudah kami kirim ke email yang terdaftar di akun Anda. Silakan cek kotak masuk.',
    role: SenderRole.agent,
    minute: 4,
  ),
  guestMessage('m-4', 'Sudah masuk emailnya, terima kasih.', minute: 6),
];

Widget _panel(GuestSupportState state, Widget child, double height) => SizedBox(
  height: height,
  child: BlocProvider<GuestSupportCubit>(create: (_) => _ReadyGuestCubit(state), child: child),
);

final guestSupportScenes = <ScreenshotScene>[
  ScreenshotScene(
    'guest_support_form',
    (context) => _panel(
      const GuestSupportState(
        phase: GuestSupportPhase.form,
        config: GuestSupportConfig(enabled: true, problems: guestProblems),
      ),
      const GuestSupportFormView(),
      980,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'guest_support_chat',
    (context) => _panel(
      GuestSupportState(
        phase: GuestSupportPhase.chat,
        token: _token,
        ticket: guestTicket(status: SupportStatus.claimed),
        messages: _messages(),
      ),
      const GuestSupportChatView(),
      760,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'guest_support_queue',
    (context) => _panel(
      GuestSupportState(
        phase: GuestSupportPhase.chat,
        token: _token,
        ticket: guestTicket(),
        messages: _messages().take(1).toList(),
        reconnecting: true,
      ),
      const GuestSupportChatView(),
      560,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'guest_support_resolved',
    (context) => _panel(
      GuestSupportState(
        phase: GuestSupportPhase.ended,
        ticket: guestTicket(status: SupportStatus.resolved),
        messages: _messages(),
        endReason: GuestSupportEndReason.resolved,
      ),
      const GuestSupportChatView(),
      760,
    ),
    padding: EdgeInsets.zero,
  ),
];

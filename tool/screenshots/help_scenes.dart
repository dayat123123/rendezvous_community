import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_topic_picker.dart';

import '../../test/support/help_fakes.dart';
import 'screenshot_harness.dart';

const _topics = [
  SupportTopic(code: 'account', name: 'Akun & Login', icon: 'account'),
  SupportTopic(code: 'funds', name: 'Deposit/Tarik Dana', icon: 'wallet'),
];

class _Support extends Fake implements SupportRepository {}

class _ReadyCubit extends SupportCubit {
  _ReadyCubit(SupportState state) : super(support: _Support()) {
    emit(state);
  }
}

void _noContact(BuildContext context, String? topic) {}

Widget _center(FakeHelpRepository help, double height) => SizedBox(
  height: height,
  child: CommunityHelpScope(
    dependencies: FakeHelpDependencies(help),
    child: const CommunityHelpCenter(onContactSupport: _noContact),
  ),
);

final helpScenes = <ScreenshotScene>[
  ScreenshotScene('help_center', (context) => _center(FakeHelpRepository(), 460), padding: EdgeInsets.zero),
  ScreenshotScene(
    'help_center_offline',
    (context) => _center(
      FakeHelpRepository(cached: helpContent(savedAt: DateTime.utc(2026, 11, 8)))
        ..centerError = const CommunityException(CommunityErrorKind.network),
      460,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene('help_article', (context) {
    final pin = pinArticle.copyWith(updatedAt: helpUpdatedAt);
    final help = FakeHelpRepository(
      content: HelpCenterContent(
        categories: [
          HelpCategory(code: 'account', name: 'Akun & Keamanan', articles: [pin]),
        ],
      ),
    )..feedbackByArticle['a-pin'] = const HelpFeedback(helpful: true);
    return SizedBox(
      height: 860,
      child: CommunityHelpArticleView(
        article: pin,
        categoryName: 'Akun & Keamanan',
        repository: help,
        onContactSupport: _noContact,
      ),
    );
  }, padding: EdgeInsets.zero),
  ScreenshotScene(
    'support_topic_suggestions',
    (context) => SizedBox(
      height: 560,
      child: BlocProvider<SupportCubit>(
        create: (_) => _ReadyCubit(
          const SupportState(
            status: LoadStatus.ready,
            home: SupportHome(supportName: 'CS OLT'),
            topics: _topics,
            suggestionTopic: 'account',
            suggestions: [pinArticle, loginArticle],
          ),
        ),
        child: const SupportTopicPicker(),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_leave_message',
    (context) => SizedBox(
      height: 560,
      child: BlocProvider<SupportCubit>(
        create: (_) => _ReadyCubit(
          SupportState(
            status: LoadStatus.ready,
            home: SupportHome(supportName: 'CS OLT', serviceOpen: false, nextOpenAt: DateTime(2026, 11, 10, 8)),
            topics: _topics,
            suggestionTopic: 'funds',
            suggestions: const [depositArticle],
            leavingMessage: true,
          ),
        ),
        child: const SupportTopicPicker(),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
];

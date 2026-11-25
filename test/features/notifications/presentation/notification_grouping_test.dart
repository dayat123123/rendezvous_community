import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/cubit/notifications_cubit.dart';

import '../../../support/fakes.dart';
import '../../../support/feature_fakes.dart';

const _carol = UserSummary(id: 'u-c', username: 'carol', displayName: 'Carol');

class _Notifications extends FakeNotificationRepository {
  _Notifications(this.pages);

  final Map<String?, Paged<AppNotification>> pages;

  @override
  Future<Paged<AppNotification>> getNotifications({String? cursor, int limit = 30}) async =>
      pages[cursor] ?? const Paged.empty();

  @override
  Future<int> unreadCount() async => 0;

  @override
  Future<void> markRead({List<String>? ids}) async {}
}

class _Media extends Fake implements MediaRepository {
  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) => Completer<AuthorizedImage>().future;
}

AppNotification _n(
  String id,
  NotificationType type, {
  List<UserSummary> actors = const [],
  int? actorCount,
  Map<String, Object?> payload = const {},
}) => AppNotification(
  id: id,
  type: type,
  actor: actors.isEmpty ? null : actors.first,
  actors: actors,
  actorCount: actorCount ?? actors.length,
  payload: payload,
  createdAt: now,
  cursor: 'c-$id',
);

Future<_Notifications> _pump(WidgetTester tester, List<AppNotification> items) async {
  final repo = _Notifications({null: Paged(items)});
  await pumpFeatureApp(
    tester,
    const CommunityNotificationList(),
    dependencies: FakeDependencies(notifications: repo, mediaRepository: _Media()),
  );
  await tester.pumpAndSettle();
  return repo;
}

String? _boldText(WidgetTester tester, String title) {
  final text = tester.widget<Text>(find.text(title));
  final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
  return spans.firstWhere((s) => s.style?.fontWeight == FontWeight.w700).text;
}

void main() {
  testWidgets('a post liked by many people reads as one row with two names', (tester) async {
    final repo = await _pump(tester, [
      _n(
        'n-1',
        NotificationType.like,
        actors: [alice, bob, _carol],
        actorCount: 100,
        payload: const {'target_type': 'post', 'post_id': 'p-1'},
      ),
    ]);
    const title = 'Alice, Bob, dan 98 lainnya menyukai postingan Anda';
    expect(find.text(title), findsOneWidget);
    expect(_boldText(tester, title), 'Alice, Bob, dan 98 lainnya');
    expect(find.byType(CommunityAvatar), findsNWidgets(2));
    await repo.dispose();
  });

  testWidgets('a comment liked by two people names both', (tester) async {
    final repo = await _pump(tester, [
      _n('n-1', NotificationType.like, actors: [alice, bob], payload: const {'target_type': 'comment'}),
    ]);
    expect(find.text('Alice dan Bob menyukai komentar Anda'), findsOneWidget);
    await repo.dispose();
  });

  testWidgets('comments on my post are grouped under one row', (tester) async {
    final repo = await _pump(tester, [
      _n('n-1', NotificationType.reply, actors: [alice], payload: const {'scope': 'post'}),
      _n('n-2', NotificationType.reply, actors: [bob], actorCount: 3, payload: const {'scope': 'comment'}),
    ]);
    expect(find.text('Alice mengomentari postingan Anda'), findsOneWidget);
    expect(find.text('Bob dan 2 lainnya membalas komentar Anda'), findsOneWidget);
    expect(find.byType(CommunityAvatar), findsNWidgets(2));
    await repo.dispose();
  });

  testWidgets('follows from several people name the newest two', (tester) async {
    final repo = await _pump(tester, [
      _n('n-1', NotificationType.follow, actors: [alice, bob]),
    ]);
    expect(find.text('Alice dan Bob mulai mengikuti Anda'), findsOneWidget);
    await repo.dispose();
  });

  testWidgets('rows about a post show its first image', (tester) async {
    final repo = await _pump(tester, [
      _n(
        'n-1',
        NotificationType.like,
        actors: [alice],
        payload: const {
          'target_type': 'post',
          'post_attachment': {'path': 'posts/u-me/foto.jpg', 'mime': 'image/jpeg'},
        },
      ),
      _n('n-2', NotificationType.follow, actors: [bob]),
    ]);
    expect(find.byType(CommunityNotificationThumbnail), findsOneWidget);
    await repo.dispose();
  });

  test('post attachment is read from the payload', () {
    final n = _n(
      'n-1',
      NotificationType.like,
      payload: const {
        'post_attachment': {'path': 'posts/u-me/foto.jpg', 'mime': 'image/jpeg', 'width': 640, 'height': 480},
      },
    );
    expect(n.postAttachment?.path, 'posts/u-me/foto.jpg');
    expect(n.postAttachment?.width, 640);
    expect(_n('n-2', NotificationType.like).postAttachment, isNull);
  });

  test('loading more skips rows already on screen', () async {
    final first = _n('n-1', NotificationType.like, actors: [alice]);
    final second = _n('n-2', NotificationType.follow, actors: [bob]);
    final repo = _Notifications({
      null: Paged([first, second], nextCursor: 'c-2'),
      'c-2': Paged([
        second,
        _n('n-3', NotificationType.reply, actors: [alice]),
      ]),
    });
    final cubit = NotificationsCubit(notifications: repo);
    await cubit.load();
    await cubit.loadMore();
    expect(cubit.state.items.map((n) => n.id), ['n-1', 'n-2', 'n-3']);
    await cubit.close();
    await repo.dispose();
  });

  testWidgets('a notice with a picture shows it on the right', (tester) async {
    final repo = await _pump(tester, [
      _n(
        'n-1',
        NotificationType.announcement,
        payload: const {
          'notice_id': 'nt-1',
          'title': 'Uji coba DRC',
          'image_url': 'https://cdn.example.com/app-banners/drc.png',
        },
      ),
      _n('n-2', NotificationType.announcement, payload: const {'notice_id': 'nt-2', 'title': 'Tanpa gambar'}),
    ]);
    expect(find.byType(CommunityNotificationThumbnail), findsOneWidget);
    await repo.dispose();
  });

  test('image url is read only when it is a web address', () {
    expect(
      _n('n-1', NotificationType.announcement, payload: const {'image_url': 'https://cdn.example.com/a.png'}).imageUrl,
      'https://cdn.example.com/a.png',
    );
    expect(_n('n-2', NotificationType.announcement, payload: const {'image_url': 'file:///etc/x'}).imageUrl, isNull);
    expect(_n('n-3', NotificationType.announcement, payload: const {'image_url': ''}).imageUrl, isNull);
    expect(_n('n-4', NotificationType.announcement).hasImage, isFalse);
  });

  testWidgets('post reactions show the emoji unless it is the thumbs up', (tester) async {
    final repo = await _pump(tester, [
      _n(
        'n-1',
        NotificationType.like,
        actors: [alice],
        payload: const {'target_type': 'post', 'post_id': 'p-1', 'emoji': '🔥'},
      ),
      _n(
        'n-2',
        NotificationType.like,
        actors: [bob],
        payload: const {'target_type': 'post', 'post_id': 'p-2', 'emoji': '👍'},
      ),
    ]);
    expect(find.text('Alice memberi reaksi 🔥 pada postingan Anda'), findsOneWidget);
    expect(_boldText(tester, 'Alice memberi reaksi 🔥 pada postingan Anda'), 'Alice');
    expect(find.text('Bob menyukai postingan Anda'), findsOneWidget);
    expect(_n('n-3', NotificationType.like, payload: const {'emoji': 'like'}).reactionEmoji, '👍');
    expect(_n('n-4', NotificationType.like).reactionEmoji, isNull);
    await repo.dispose();
  });
}

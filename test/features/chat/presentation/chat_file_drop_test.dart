import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

const _dropHint = 'Lepas file di sini untuk dikirim';

final _pdf = Uint8List.fromList('%PDF-1.4\n%%EOF'.codeUnits);

final _at = DropEventDetails(localPosition: Offset.zero, globalPosition: Offset.zero);

Future<void> _pumpRoom(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(
            chat: FakeChatRepository(rooms: [directRoom()], members: directMembers()),
          ),
          child: const CommunityChatRoom(roomId: 'dm', composer: MessageComposer(allowDocuments: true)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DropTarget _target(WidgetTester tester) => tester.widget<DropTarget>(find.byType(DropTarget));

Future<void> _drop(WidgetTester tester, List<DropItem> files) async {
  _target(tester).onDragEntered!(_at);
  await tester.pump();
  _target(tester).onDragDone!(DropDoneDetails(files: files, localPosition: Offset.zero, globalPosition: Offset.zero));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dragging files over the chat shows where to drop them', (tester) async {
    await _pumpRoom(tester);
    expect(find.text(_dropHint), findsNothing);

    _target(tester).onDragEntered!(_at);
    await tester.pump();
    expect(find.text(_dropHint), findsOneWidget);

    _target(tester).onDragExited!(_at);
    await tester.pump();
    expect(find.text(_dropHint), findsNothing);
  });

  testWidgets('a dropped file waits in the composer like a picked one', (tester) async {
    await _pumpRoom(tester);
    await _drop(tester, [DropItemFile.fromData(_pdf, path: 'laporan.pdf', mimeType: 'application/pdf')]);
    expect(find.text(_dropHint), findsNothing);
    expect(find.text('laporan.pdf'), findsOneWidget);
  });

  testWidgets('dropped folders are ignored', (tester) async {
    await _pumpRoom(tester);
    await _drop(tester, [
      DropItemDirectory('C:/docs', [DropItemFile.fromData(_pdf, path: 'di-dalam.pdf', mimeType: 'application/pdf')]),
    ]);
    expect(find.text('di-dalam.pdf'), findsNothing);
    expect(find.text(_dropHint), findsNothing);
  });
}

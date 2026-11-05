import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rendezvous_community/rendezvous_community.dart';

class ScreenshotScene {
  const ScreenshotScene(this.name, this.builder, {this.width = 400, this.padding = const EdgeInsets.all(16)});

  final String name;
  final WidgetBuilder builder;
  final double width;
  final EdgeInsets padding;
}

const screenshotSeed = Color(0xFF0B5FFF);

final screenshotOutput = Directory(p.join(Directory.current.path, 'build', 'screenshots'));

ThemeData screenshotTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: screenshotSeed, brightness: brightness),
  platform: TargetPlatform.android,
);

Directory _materialFonts() {
  final root = Platform.environment['FLUTTER_ROOT'];
  final candidates = [
    if (root != null) p.join(root, 'bin', 'cache', 'artifacts', 'material_fonts'),
    for (var dir = File(Platform.resolvedExecutable).parent; dir.parent.path != dir.path; dir = dir.parent)
      p.join(dir.path, 'material_fonts'),
  ];
  for (final path in candidates) {
    final dir = Directory(path);
    if (File(p.join(dir.path, 'roboto-regular.ttf')).existsSync()) return dir;
  }
  throw StateError('material_fonts tidak ditemukan; jalankan `flutter precache` atau set FLUTTER_ROOT');
}

Future<ByteData> _font(Directory dir, String file) async =>
    ByteData.sublistView(Uint8List.fromList(await File(p.join(dir.path, file)).readAsBytes()));

Future<void> loadScreenshotFonts() async {
  final dir = _materialFonts();
  final roboto = FontLoader('Roboto');
  for (final file in [
    'roboto-light.ttf',
    'roboto-regular.ttf',
    'roboto-italic.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ]) {
    roboto.addFont(_font(dir, file));
  }
  await roboto.load();
  await (FontLoader('MaterialIcons')..addFont(_font(dir, 'materialicons-regular.otf'))).load();
}

Future<File> captureScene(WidgetTester tester, ScreenshotScene scene, Brightness brightness) async {
  const ratio = 2.0;
  final key = GlobalKey();
  tester.view.devicePixelRatio = ratio;
  tester.view.physicalSize = Size(scene.width * ratio, 2400 * ratio);
  addTearDown(tester.view.reset);
  final theme = screenshotTheme(brightness);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final style = CommunityStyle.of(context);
          return Material(
            color: style.background,
            child: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: key,
                child: Container(
                  width: scene.width,
                  color: style.background,
                  padding: scene.padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [Builder(builder: scene.builder)],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 100));
  final file = File(p.join(screenshotOutput.path, '${scene.name}_${brightness.name}.png'));
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
    final image = await boundary.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
  return file;
}

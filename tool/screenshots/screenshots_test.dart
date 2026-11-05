import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_scenes.dart';
import 'feed_scenes.dart';
import 'screenshot_harness.dart';
import 'settings_scenes.dart';
import 'shared_scenes.dart';
import 'support_scenes.dart';
import 'system_scenes.dart';

final scenes = <ScreenshotScene>[
  ...sharedScenes,
  ...supportScenes,
  ...settingsScenes,
  ...systemScenes,
  ...feedScenes,
  ...stockScenes,
  ...detailScenes,
  ...stateScenes,
  ...chatScenes,
];

void main() {
  setUpAll(loadScreenshotFonts);

  for (final scene in scenes) {
    for (final brightness in Brightness.values) {
      testWidgets('${scene.name} ${brightness.name}', (tester) async {
        final file = await captureScene(tester, scene, brightness);
        expect(tester.takeException(), isNull);
        expect(file.existsSync(), isTrue);
      });
    }
  }
}

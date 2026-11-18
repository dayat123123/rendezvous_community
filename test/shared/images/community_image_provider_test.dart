import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a failed image leaves the image cache so the next build loads it again', () async {
    final loader = CommunityImageLoader(client: MockClient((request) async => http.Response('', 503)));
    final provider = CommunityImageProvider(
      cacheKey: 'storage:attachments/posts/u/a.png',
      source: () async => const AuthorizedImage('http://api.test/a.png', {}),
      loader: loader,
      persist: false,
    );
    final cache = PaintingBinding.instance.imageCache;
    addTearDown(cache.clear);

    final failed = Completer<Object>();
    provider
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((_, _) {}, onError: (error, _) => failed.complete(error)));

    expect(await failed.future, isA<CommunityImageLoadException>());
    await pumpEventQueue();
    expect(cache.containsKey(provider), isFalse);
  });
}

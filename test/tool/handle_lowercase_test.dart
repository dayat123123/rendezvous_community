import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../tool/source_files.dart';

final _rawHandle = RegExp(r'''['"]@\$''');

const _definition = 'lib/src/shared/domain/entities/user.dart';

List<String> _rawHandlesIn(String path, String source) => [
  for (final (index, line) in source.split('\n').indexed)
    if (_rawHandle.hasMatch(line)) '$path:${index + 1}',
];

void main() {
  test('handle and communityHandle are lowercase', () {
    expect(const UserSummary(id: 'u', username: 'BudiSantoso').handle, '@budisantoso');
    expect(communityHandle('Pak_RT.01'), '@pak_rt.01');
  });

  test('library widgets build @handles only through handle or communityHandle', () {
    final packageRoot = Directory.current;
    final found = [
      for (final file in handwrittenDartFiles(packageRoot))
        if (relativePath(packageRoot, file).startsWith('lib/') && relativePath(packageRoot, file) != _definition)
          ..._rawHandlesIn(relativePath(packageRoot, file), file.readAsStringSync()),
    ];
    expect(found, isEmpty);
  });

  test('the checker reports a raw handle', () {
    const source = '''
final a = '@\${user.username}';
final b = user.handle;
final c = "@\$name";
''';
    expect(_rawHandlesIn('x.dart', source), ['x.dart:1', 'x.dart:3']);
  });
}

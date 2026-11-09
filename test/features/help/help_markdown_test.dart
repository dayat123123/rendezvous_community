import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/src/features/help/domain/services/help_markdown.dart';

import '../../support/help_fakes.dart';

void main() {
  group('parseHelpInlines', () {
    test('bold, italic and plain text keep their order', () {
      expect(parseHelpInlines('Buka **Profil** lalu *Keamanan*.'), const [
        HelpInline('Buka '),
        HelpInline('Profil', bold: true),
        HelpInline(' lalu '),
        HelpInline('Keamanan', italic: true),
        HelpInline('.'),
      ]);
    });

    test('italic inside bold and underscore italic', () {
      expect(parseHelpInlines('**sangat _penting_**'), const [
        HelpInline('sangat ', bold: true),
        HelpInline('penting', bold: true, italic: true),
      ]);
    });

    test('https links become tappable, other schemes keep only the label', () {
      expect(parseHelpInlines('Lihat [panduan](https://olt.co.id/bantuan) atau [ini](javascript:alert(1))'), [
        const HelpInline('Lihat '),
        HelpInline('panduan', link: Uri.parse('https://olt.co.id/bantuan')),
        const HelpInline(' atau ini)'),
      ]);
      expect(parseHelpInlines('[web](http://olt.co.id)'), const [HelpInline('web')]);
      expect(parseHelpInlines('[x](https://user:pw@olt.co.id)'), const [HelpInline('x')]);
    });

    test('unmatched markers, snake_case and escapes stay literal', () {
      expect(parseHelpInlines('2 * 3 = 6 dan kode_saham_baru'), const [HelpInline('2 * 3 = 6 dan kode_saham_baru')]);
      expect(parseHelpInlines(r'\*bukan miring\*'), const [HelpInline('*bukan miring*')]);
      expect(parseHelpInlines('**belum ditutup'), const [HelpInline('**belum ditutup')]);
    });

    test('HTML is rendered as plain text', () {
      expect(parseHelpInlines('<b>tebal</b>'), const [HelpInline('<b>tebal</b>')]);
    });

    test('an inline image is reduced to its alt text and never becomes a link', () {
      expect(parseHelpInlines('Lihat ![contoh layar]($helpImageUrl) di atas'), const [
        HelpInline('Lihat contoh layar di atas'),
      ]);
    });
  });

  group('parseHelpMarkdown', () {
    test('paragraphs, bullet and ordered lists, headings', () {
      final blocks = parseHelpMarkdown(
        '# Langkah\nBaris satu\nbaris dua\n\n- Periksa sinyal\n- Perbarui *aplikasi*\n\n3. Tiga\n4. Empat',
      );
      expect(blocks, hasLength(4));
      final heading = blocks[0] as HelpHeadingBlock;
      expect(heading.level, 1);
      expect(heading.inlines, const [HelpInline('Langkah')]);
      expect((blocks[1] as HelpParagraphBlock).inlines, const [HelpInline('Baris satu\nbaris dua')]);
      final bullets = blocks[2] as HelpListBlock;
      expect(bullets.ordered, isFalse);
      expect(bullets.items, hasLength(2));
      expect(bullets.items[1], const [HelpInline('Perbarui '), HelpInline('aplikasi', italic: true)]);
      final numbers = blocks[3] as HelpListBlock;
      expect(numbers.ordered, isTrue);
      expect(numbers.start, 3);
      expect(numbers.items.map((i) => i.single.text), ['Tiga', 'Empat']);
    });

    test('a bold line is a paragraph, not a list item', () {
      final blocks = parseHelpMarkdown('**Catatan:** simpan PIN Anda');
      expect(blocks.single, isA<HelpParagraphBlock>());
    });

    test('indented lines continue the previous list item', () {
      final list = parseHelpMarkdown('- Satu\n  lanjutan\n- Dua').single as HelpListBlock;
      expect(list.items.first.single.text, 'Satu\nlanjutan');
    });

    test('Windows line endings and blank input', () {
      expect(parseHelpMarkdown('A\r\n\r\nB'), hasLength(2));
      expect(parseHelpMarkdown('  \n\n'), isEmpty);
    });

    test('images from the faq-images bucket on their own line become image blocks', () {
      final blocks = parseHelpMarkdown('Contoh:\n![Layar ganti PIN]($helpImageUrl)\nSelesai.');
      expect(blocks, hasLength(3));
      final image = blocks[1] as HelpImageBlock;
      expect(image.uri, Uri.parse(helpImageUrl));
      expect(image.alt, 'Layar ganti PIN');
      final dev = parseHelpMarkdown(
        '![](http://localhost:8000/storage/v1/object/public/faq-images/3f2b8c1e-5d4a-4b6f-9e21-7a0c9d8e1f23.webp)',
      );
      expect((dev.single as HelpImageBlock).alt, isEmpty);
    });

    test('images outside the faq-images bucket are not loaded', () {
      for (final url in [
        'https://evil.example/track.png',
        'https://olt.co.id/storage/v1/object/public/avatars/3f2b8c1e-5d4a-4b6f-9e21-7a0c9d8e1f23.png',
        'https://olt.co.id/storage/v1/object/public/faq-images/3f2b8c1e-5d4a-4b6f-9e21-7a0c9d8e1f23.svg',
        'https://olt.co.id/storage/v1/object/public/faq-images/3f2b8c1e-5d4a-4b6f-9e21-7a0c9d8e1f23.png?x=1',
        'ftp://olt.co.id/storage/v1/object/public/faq-images/3f2b8c1e-5d4a-4b6f-9e21-7a0c9d8e1f23.png',
      ]) {
        final blocks = parseHelpMarkdown('![gambar]($url)');
        expect(blocks.single, isA<HelpParagraphBlock>(), reason: url);
        expect((blocks.single as HelpParagraphBlock).inlines, const [HelpInline('gambar')], reason: url);
      }
      expect(parseHelpMarkdown('![](https://evil.example/track.png)'), isEmpty);
    });
  });
}

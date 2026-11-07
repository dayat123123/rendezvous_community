import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart';

void main() {
  group('extractCashtags', () {
    test('extracts unique uppercase stock codes in order', () {
      expect(extractCashtags(r'Beli $BBCA dan $goto, lalu $bbca lagi ($ABC).'), ['BBCA', 'GOTO', 'ABC']);
    });

    test('ignores prices and currency symbols', () {
      expect(extractCashtags(r'harga $100, US$5, $1BBCA'), isEmpty);
    });

    test('supports index codes and digits after letters', () {
      expect(extractCashtags(r'$IHSG dan $IDX30 naik'), ['IHSG', 'IDX30']);
    });

    test('ignores codes attached to letters, digits, or _', () {
      expect(extractCashtags(r'a$BBCA _$TLKM $BBCA_x $TLKMx'), ['TLKMX']);
    });

    test('allows at most 12 characters after \$', () {
      expect(extractCashtags(r'$ABCDEFGHIJKL ok, $ABCDEFGHIJKLM tidak'), ['ABCDEFGHIJKL']);
    });
  });

  group('extractMentions', () {
    test('extracts unique lowercase usernames', () {
      expect(extractMentions('cc @Budi_Santoso dan @sari, @budi_santoso!'), ['budi_santoso', 'sari']);
    });

    test('ignores emails and usernames that are too short', () {
      expect(extractMentions('kirim ke budi@mail.com atau @al'), isEmpty);
    });
  });

  group('parseSocialText', () {
    test('splits text into plain, cashtag, and mention segments', () {
      final segments = parseSocialText(r'Halo @budi_s, $BBCA naik!');
      expect(segments.map((s) => s.runtimeType).toList(), [
        PlainSegment,
        MentionSegment,
        PlainSegment,
        CashtagSegment,
        PlainSegment,
      ]);
      expect(segments.map((s) => s.text).join(), r'Halo @budi_s, $BBCA naik!');
      expect((segments[1] as MentionSegment).username, 'budi_s');
      expect((segments[3] as CashtagSegment).code, 'BBCA');
    });

    test('validStockCodes limits which codes are tappable', () {
      final segments = parseSocialText(r'$BBCA dan $ZZZZ', validStockCodes: {'BBCA'});
      expect(segments.whereType<CashtagSegment>().map((s) => s.code), ['BBCA']);
      expect(segments.map((s) => s.text).join(), r'$BBCA dan $ZZZZ');
    });

    test('turns text without tags into a single plain segment', () {
      expect(parseSocialText('biasa saja').single, isA<PlainSegment>());
    });
  });

  group('findActiveToken', () {
    test('detects a \$ being typed', () {
      final token = findActiveToken(r'lihat $BB', 9)!;
      expect(token.trigger, r'$');
      expect(token.query, 'BB');
      expect(token.start, 6);
    });

    test('detects @ at the start of the text', () {
      final token = findActiveToken('@bu', 3)!;
      expect(token.trigger, '@');
      expect(token.query, 'bu');
      expect(token.start, 0);
    });

    test('is inactive inside a word or after a space', () {
      expect(findActiveToken('email@do', 8), isNull);
      expect(findActiveToken(r'$BBCA ', 6), isNull);
    });
  });

  group('parseSocialText contacts and www links', () {
    List<(String, String)> linksIn(String text, {bool contacts = true}) => [
      for (final s in parseSocialText(text, links: true, contacts: contacts))
        if (s is LinkSegment) (s.text, s.uri.toString()),
    ];

    test('detects www links without a scheme as https', () {
      expect(linksIn('Buka www.evergreensekuritas.co.id/bantuan, atau WWW.OLT.co.id.'), [
        ('www.evergreensekuritas.co.id/bantuan', 'https://www.evergreensekuritas.co.id/bantuan'),
        ('WWW.OLT.co.id', 'https://www.olt.co.id'),
      ]);
      expect(linksIn('www. kosong dan swww.x.com'), isEmpty);
    });

    test('detects emails as mailto links and does not treat their domain as a mention', () {
      final segments = parseSocialText(
        'Kirim ke cs.olt+bantuan@evergreen.co.id. Terima kasih',
        links: true,
        contacts: true,
      );
      expect(segments.whereType<MentionSegment>(), isEmpty);
      expect(linksIn('Kirim ke cs.olt+bantuan@evergreen.co.id. Terima kasih'), [
        ('cs.olt+bantuan@evergreen.co.id', 'mailto:cs.olt+bantuan@evergreen.co.id'),
      ]);
    });

    test('detects Indonesian phone numbers as tel links', () {
      expect(linksIn('Hubungi 0812-3456-7890 atau +62 21 5091 2345, kantor 021-5091234'), [
        ('0812-3456-7890', 'tel:081234567890'),
        ('+62 21 5091 2345', 'tel:+622150912345'),
        ('021-5091234', 'tel:0215091234'),
      ]);
    });

    test('leaves dates, ticket numbers, account numbers and short numbers as text', () {
      expect(linksIn('Tiket CS-20261107-0003 tanggal 07-11-2026, RDN 1040004235789, kode 081234'), isEmpty);
    });

    test('keeps a link whole when it contains an email or a number', () {
      expect(linksIn('https://olt.test/u/budi@mail.com dan https://olt.test/08123456789'), [
        ('https://olt.test/u/budi@mail.com', 'https://olt.test/u/budi@mail.com'),
        ('https://olt.test/08123456789', 'https://olt.test/08123456789'),
      ]);
    });

    test('contacts are off unless asked, and cashtags and mentions can be turned off', () {
      expect(linksIn('budi@mail.com 081234567890', contacts: false), isEmpty);
      final plain = parseSocialText(r'Halo @budi, $BBCA naik', cashtags: false, mentions: false);
      expect(plain.map((s) => s.runtimeType).toList(), [PlainSegment]);
    });
  });
}

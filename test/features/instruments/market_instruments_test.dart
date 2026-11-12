import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart' show findActiveToken;
import 'package:rendezvous_community/src/features/stocks/data/repositories/stock_repository_impl.dart';

import '../../support/mock_api.dart';

const _instruments = [
  MarketInstrument(code: 'IHSG', name: 'Indeks Harga Saham Gabungan', aliases: ['COMPOSITE', 'JCI']),
  MarketInstrument(code: 'SRI-KEHATI', name: 'Indeks SRI-KEHATI', aliases: ['SRIKEHATI'], position: 1),
  MarketInstrument(code: 'LQ45', name: 'Indeks LQ45', position: 2, roomEnabled: false),
];

class _Repository implements MarketInstrumentRepository {
  var calls = 0;
  Object? error;

  @override
  Future<List<MarketInstrument>> getMarketInstruments() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return _instruments;
  }
}

MarketInstrumentDirectory _directory() => MarketInstrumentDirectory()..replace(_instruments);

void main() {
  group('stock codes', () {
    test('accept plain and hyphenated codes', () {
      expect(isStockCodeFormat('BBCA'), isTrue);
      expect(isStockCodeFormat('SRI-KEHATI'), isTrue);
      expect(isStockCodeFormat('IDXSMC-LIQ'), isTrue);
      expect(isStockCodeFormat('-AB'), isFalse);
      expect(isStockCodeFormat('A'), isFalse);
      expect(isPlainStockCode('SRI-KEHATI'), isFalse);
      expect(normalizeStockCode(r' $sri-kehati '), 'SRI-KEHATI');
    });
  });

  group('MarketInstrumentDirectory', () {
    test('maps aliases to the main code and keeps plain stock codes', () {
      final directory = _directory();

      expect(directory.canonical(r'$composite'), 'IHSG');
      expect(directory.canonical('srikehati'), 'SRI-KEHATI');
      expect(directory.canonical('BBCA'), 'BBCA');
      expect(directory.canonical('ABC-DEF'), isNull);
      expect(directory.canonicalOr('ABC-DEF'), 'ABC-DEF');
      expect(directory.isIndex('JCI'), isTrue);
      expect(directory.isIndex('BBCA'), isFalse);
      expect(directory.find('LQ45')?.roomEnabled, isFalse);
    });

    test('searches by code, alias and name', () {
      final directory = _directory();

      expect(directory.search('SRI').map((i) => i.code), ['SRI-KEHATI']);
      expect(directory.search('comp').map((i) => i.code), ['IHSG']);
      expect(directory.search('gabungan').map((i) => i.code), ['IHSG']);
      expect(directory.search('Indeks', limit: 2), hasLength(2));
    });

    test('loads once, refreshes when stale and retries a failure after a minute', () async {
      var clock = DateTime(2026, 11, 12, 9);
      final repository = _Repository();
      final directory = MarketInstrumentDirectory(repository, const Duration(minutes: 10), () => clock);
      var notified = 0;
      directory.addListener(() => notified++);

      await Future.wait([directory.load(), directory.load()]);
      expect(repository.calls, 1);
      expect(directory.loaded, isTrue);
      expect(notified, 1);

      clock = clock.add(const Duration(minutes: 5));
      await directory.load();
      expect(repository.calls, 1);

      clock = clock.add(const Duration(minutes: 6));
      repository.error = const CommunityException(CommunityErrorKind.network);
      await directory.load();
      expect(repository.calls, 2);
      expect(directory.instruments, hasLength(3));

      await directory.load();
      expect(repository.calls, 2);
      clock = clock.add(const Duration(minutes: 2));
      repository.error = null;
      await directory.load();
      expect(repository.calls, 3);
    });

    test('one directory per source, unsupported sources stay empty', () {
      final source = Object();

      expect(
        identical(MarketInstrumentDirectory.forSource(source), MarketInstrumentDirectory.forSource(source)),
        isTrue,
      );
      expect(MarketInstrumentDirectory.forSource(source).supported, isFalse);
      expect(MarketInstrumentDirectory.forSource(_Repository()).supported, isTrue);
    });
  });

  group('cashtag parsing', () {
    test('a suffix after a stock code is not part of the code', () {
      expect(extractCashtags(r'Lihat $BBCA-nya naik'), ['BBCA']);
      final segments = parseSocialText(r'Lihat $BBCA-nya naik');
      expect(segments[1], isA<CashtagSegment>().having((s) => s.text, 'text', r'$BBCA'));
      expect(segments[2], isA<PlainSegment>().having((s) => s.text, 'text', '-nya naik'));
    });

    test('registered hyphenated codes and aliases resolve through the directory', () {
      final directory = _directory();

      expect(extractCashtags(r'$SRI-KEHATI, $sri-kehati-nya, $composite, $IHSG', resolve: directory.resolveCashtag), [
        'SRI-KEHATI',
        'IHSG',
      ]);
      final segments = parseSocialText(r'$SRI-KEHATI-nya', resolveCashtag: directory.resolveCashtag);
      expect(
        segments.first,
        isA<CashtagSegment>().having((s) => s.text, 'text', r'$SRI-KEHATI').having((s) => s.code, 'code', 'SRI-KEHATI'),
      );
    });

    test('unknown hyphenated codes fall back to the part before the hyphen', () {
      expect(extractCashtags(r'$ABC-DEF $A $ABCDEFGHIJKLMNOPQRSTU'), ['ABC']);
    });

    test('valid stock codes from the post keep hyphenated codes without a directory', () {
      final segments = parseSocialText(r'Rebound $SRI-KEHATI', validStockCodes: {'SRI-KEHATI'});

      expect(segments.last, isA<CashtagSegment>().having((s) => s.code, 'code', 'SRI-KEHATI'));
    });

    test('aliases match the valid codes of a post through the directory', () {
      final segments = parseSocialText(
        r'Naik $composite',
        validStockCodes: {'IHSG'},
        resolveCashtag: _directory().resolveCashtag,
      );

      expect(segments.last, isA<CashtagSegment>().having((s) => s.code, 'code', 'IHSG'));
    });

    test('the composer keeps the active token across a hyphen', () {
      final token = findActiveToken(r'Bahas $SRI-KE', 13)!;

      expect(token.trigger, r'$');
      expect(token.query, 'SRI-KE');
      expect(findActiveToken('halo @budi_s', 12)!.query, 'budi_s');
      expect(findActiveToken('halo @budi-s', 12), isNull);
    });
  });

  group('StockRepositoryImpl.getMarketInstruments', () {
    test('maps rows from get_market_instruments', () async {
      final api = mockApi();
      when(() => api.rpcRows('get_market_instruments', any())).thenAnswer(
        (_) async => [
          {
            'code': 'SRI-KEHATI',
            'kind': 'index',
            'name': 'Indeks SRI-KEHATI',
            'description': 'Indeks berkelanjutan',
            'aliases': ['srikehati'],
            'position': 8,
            'room_enabled': false,
          },
          {'code': 'X', 'kind': 'future', 'name': 'Tidak dikenal'},
        ],
      );

      final items = await StockRepositoryImpl(api).getMarketInstruments();

      expect(items, [
        const MarketInstrument(
          code: 'SRI-KEHATI',
          name: 'Indeks SRI-KEHATI',
          description: 'Indeks berkelanjutan',
          aliases: ['SRIKEHATI'],
          position: 8,
          roomEnabled: false,
        ),
      ]);
    });

    test('an older server without the directory returns an empty list', () async {
      final api = mockApi();
      when(
        () => api.rpcRows('get_market_instruments', any()),
      ).thenThrow(const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202'));

      expect(await StockRepositoryImpl(api).getMarketInstruments(), isEmpty);
    });
  });
}

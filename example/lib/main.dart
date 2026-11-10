import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import 'custom_chat_style.dart';
import 'custom_feed_style.dart';
import 'fake_olt_auth.dart';
import 'stock_directory.dart';

const _anonKey = String.fromEnvironment('OLT_SOCIAL_ANON_KEY');
const _urlOverride = String.fromEnvironment('OLT_SOCIAL_URL');
const _dummyOltOverride = String.fromEnvironment('OLT_DUMMY_WS_URL');
const _promoPopups = bool.fromEnvironment('OLT_PROMO_POPUP', defaultValue: true);

String get socialUrl {
  if (_urlOverride.isNotEmpty) return _urlOverride;
  if (kIsWeb) return 'http://${Uri.base.host}:8000';
  return defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
}

final exampleGuestSupport = CommunityGuestSupportClient.anonymous(supabaseUrl: socialUrl, anonKey: _anonKey);

bool get _desktop =>
    !kIsWeb && {TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux}.contains(defaultTargetPlatform);

String? get autoLoginUser => kIsWeb ? Uri.base.queryParameters['user'] : null;

String get dummyOltWsUrl => _dummyOltOverride.isNotEmpty
    ? _dummyOltOverride
    : Uri.parse(socialUrl).replace(scheme: 'ws', port: 8090, path: '/ws').toString();

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key, this.promoPopups = _promoPopups});

  final bool promoPopups;

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('id');
  bool _customChat = false;
  bool _customFeed = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5FFF), brightness: brightness),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'OLT Social Example',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: _anonKey.isEmpty ? const _MissingConfigPage() : const LoginPage(onSignedIn: _startSocial),
      builder: (context, child) => _SettingsScope(
        promoPopups: widget.promoPopups,
        toggleTheme: () => setState(() {
          _themeMode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
        }),
        toggleLocale: () => setState(() {
          _locale = _locale.languageCode == 'id' ? const Locale('en') : const Locale('id');
        }),
        toggleChatStyle: () => setState(() => _customChat = !_customChat),
        toggleFeedStyle: () => setState(() => _customFeed = !_customFeed),
        child: CommunityBuildersScope(
          builders: CommunityBuilders(
            chat: _customChat ? customChatBuilders : const CommunityChatBuilders(),
            feed: _customFeed ? customFeedBuilders : const CommunityFeedBuilders(),
            badges: _customFeed ? customBadgeBuilders : const CommunityBadgeBuilders(),
          ),
          child: CommunityGuestSupportScope(dependencies: exampleGuestSupport, child: child!),
        ),
      ),
    );
  }
}

Future<void> _startSocial(FakeOltAuth auth) async {
  final social = await RendezvousCommunity.initialize(
    supabaseUrl: socialUrl,
    anonKey: _anonKey,
    tokenProvider: auth.token,
    onStockTap: openStockPage,
    stockSearch: searchStocks,
    stockInfo: (code) => stockNames.containsKey(code) ? CommunityStockInfo(name: stockNames[code]) : null,
    onOltNotificationTap: showOltNotification,
    onBannerLink: openPromoLink,
    appVersion: '1.3.0',
    scroll: CommunityScrollSettings(behavior: const CommunityMouseDragScrollBehavior(), pullToRefresh: !_desktop),
  );
  await social.ensureSignedIn();
}

class _SettingsScope extends InheritedWidget {
  const _SettingsScope({
    required this.promoPopups,
    required this.toggleTheme,
    required this.toggleLocale,
    required this.toggleChatStyle,
    required this.toggleFeedStyle,
    required super.child,
  });

  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  final VoidCallback toggleChatStyle;
  final VoidCallback toggleFeedStyle;
  final bool promoPopups;

  @override
  bool updateShouldNotify(_SettingsScope oldWidget) => false;
}

void toggleTheme(BuildContext context) => context.getInheritedWidgetOfExactType<_SettingsScope>()?.toggleTheme();

void toggleLocale(BuildContext context) => context.getInheritedWidgetOfExactType<_SettingsScope>()?.toggleLocale();

void toggleChatStyle(BuildContext context) =>
    context.getInheritedWidgetOfExactType<_SettingsScope>()?.toggleChatStyle();

void toggleFeedStyle(BuildContext context) =>
    context.getInheritedWidgetOfExactType<_SettingsScope>()?.toggleFeedStyle();

Widget withPromoPopups(BuildContext context, Widget child) => CommunityPromoPopupHost(
  enabled: context.getInheritedWidgetOfExactType<_SettingsScope>()?.promoPopups ?? false,
  child: child,
);

bool openPromoLink(BuildContext context, Uri uri, CommunityBanner banner) {
  if (uri.scheme != 'olt') return false;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(banner.title)),
        body: Center(child: Text('Halaman promo OLT\n$uri', textAlign: TextAlign.center)),
      ),
    ),
  );
  return true;
}

void openStockPage(BuildContext context, String code) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Halaman saham OLT · $code')),
        body: CommunityStockFeed(stockCode: code, stockName: stockNames[code]),
      ),
    ),
  );
}

class _MissingConfigPage extends StatelessWidget {
  const _MissingConfigPage();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'OLT_SOCIAL_ANON_KEY is not set.\n\n'
          'Run with:\nflutter run --dart-define=OLT_SOCIAL_ANON_KEY=<ANON_KEY: make anon-key>',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

void showOltNotification(BuildContext context, Map<String, Object?> data) {
  final title = data['title'];
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title is Map ? '${title['id'] ?? title['en'] ?? 'Notifikasi OLT'}' : '${title ?? 'Notifikasi OLT'}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in data.entries)
              if (entry.key != 'title') Text('${entry.key}: ${entry.value}'),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tutup'))],
    ),
  );
}

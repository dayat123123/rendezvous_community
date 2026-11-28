import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Future<void> showCommunityPostQuotes(BuildContext context, Post post) {
  final deps = CommunityScope.of(context);
  final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
  final l10n = context.communityL10n;
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) {
        final page = CommunityScope(
          dependencies: deps,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.quotesTitle)),
            body: SafeArea(child: CommunityPostQuotes(postId: post.id)),
          ),
        );
        return features == null ? page : CommunityFeatureScope(dependencies: features, child: page);
      },
    ),
  );
}

class CommunityPostQuotes extends StatefulWidget {
  const CommunityPostQuotes({super.key, required this.postId});

  final String postId;

  @override
  State<CommunityPostQuotes> createState() => _CommunityPostQuotesState();
}

class _CommunityPostQuotesState extends State<CommunityPostQuotes> {
  final _posts = <Post>[];
  String? _cursor;
  bool _loading = false;
  bool _done = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final repo = CommunityScope.of(context).feed;
    if (repo is! QuoteRepository) {
      setState(() => _done = true);
      return;
    }
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await (repo as QuoteRepository).postQuotes(widget.postId, cursor: _cursor);
      if (!mounted) return;
      setState(() {
        _posts.addAll(page.items);
        _cursor = page.nextCursor;
        _done = !page.hasMore;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    final error = _error;
    if (_posts.isEmpty) {
      if (error != null) return CommunityErrorView(error: error, onRetry: _load);
      if (_loading || !_done) return const CommunityLoadingView();
      return CommunityEmptyView(message: l10n.quotesEmpty, icon: Icons.format_quote_outlined);
    }
    return ListView.separated(
      addAutomaticKeepAlives: false,
      itemCount: _posts.length + (_done ? 0 : 1),
      separatorBuilder: (_, _) => const CommunityDivider(),
      itemBuilder: (context, index) {
        if (index >= _posts.length) {
          return Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Center(
              child: error != null
                  ? TextButton(onPressed: _load, child: Text(l10n.retry))
                  : _loading
                  ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(onPressed: _load, child: Text(l10n.quotesLoadMore)),
            ),
          );
        }
        final post = _posts[index];
        return PostCard(
          post: post,
          onLike: () {},
          showActions: false,
          source: 'quotes',
          onOpen: () => CommunityNavigator.openPost(context, post.id),
        );
      },
    );
  }
}

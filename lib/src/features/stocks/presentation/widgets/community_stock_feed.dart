import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/post_open_mode.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/community_feed_list.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/compose_prompt_card.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/features/stocks/presentation/cubit/stock_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityStockFeed extends StatelessWidget {
  const CommunityStockFeed({
    super.key,
    required this.stockCode,
    this.stockName,
    this.showHeader = true,
    this.postOpenMode = CommunityPostOpenMode.navigate,
  });

  final String stockCode;

  final CommunityPostOpenMode postOpenMode;

  final String? stockName;

  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final code = stockCode.toUpperCase();
    return BlocProvider(
      create: (_) => StockCubit(stocks: deps.stocks, chat: deps.chat, code: code)..load(),
      child: BlocListener<StockCubit, StockState>(
        listenWhen: (a, b) => a.errorId != b.errorId,
        listener: (context, state) => showCommunityError(context, state.error!),
        child: CommunityFeedList(
          scope: FeedScope.stock(code),
          postOpenMode: postOpenMode,
          emptyMessage: context.communityL10n.stockFeedEmpty(code),
          header: Column(
            children: [
              if (showHeader) _StockHeader(name: stockName),
              CommunityComposePromptCard(initialStock: code),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockHeader extends StatelessWidget {
  const _StockHeader({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, state) {
        final cubit = context.read<StockCubit>();
        final stock = state.stock;
        final details = CommunityStockHeaderDetails(
          code: cubit.code,
          name: name,
          subtitle: stock != null
              ? [?name, l10n.watchers(stock.watcherCount)].join(' · ')
              : state.loaded
              ? l10n.stockNotFound
              : null,
          found: stock != null,
          loaded: state.loaded,
          watching: state.watching,
          joining: state.joining,
          watchLabel: state.watching ? l10n.watching : l10n.watch,
          discussionLabel: l10n.stockDiscussion,
          onToggleWatch: stock == null ? null : cubit.toggleWatch,
          onOpenDiscussion: stock == null || state.joining
              ? null
              : () async {
                  final roomId = await cubit.joinDiscussion();
                  if (roomId != null && context.mounted) CommunityNavigator.openRoom(context, roomId);
                },
        );
        return buildFeedPart((b) => b.stockHeader, context, details, _DefaultStockHeader(details: details));
      },
    );
  }
}

class _DefaultStockHeader extends StatelessWidget {
  const _DefaultStockHeader({required this.details});

  final CommunityStockHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final subtitle = details.subtitle;
    final size = style.avatarSizes.large - spacing.lg;
    return EditorialSection(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: style.accentMuted, shape: BoxShape.circle),
                child: Icon(Icons.show_chart, color: style.accent),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${details.code}', style: style.typography.title.copyWith(fontSize: 20)),
                    if (subtitle != null)
                      Text(subtitle, style: style.typography.meta, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          if (details.found) ...[
            SizedBox(height: spacing.md),
            Row(
              children: [
                details.watching
                    ? OutlinedButton.icon(
                        style: style.secondaryButtonStyle(),
                        onPressed: details.onToggleWatch,
                        icon: Icon(Icons.star, size: 18, color: style.accent),
                        label: Text(details.watchLabel),
                      )
                    : FilledButton.icon(
                        style: style.primaryButtonStyle(),
                        onPressed: details.onToggleWatch,
                        icon: const Icon(Icons.star_border, size: 18),
                        label: Text(details.watchLabel),
                      ),
                SizedBox(width: spacing.sm),
                OutlinedButton.icon(
                  style: style.secondaryButtonStyle(),
                  onPressed: details.onOpenDiscussion,
                  icon: const Icon(Icons.forum_outlined, size: 18),
                  label: Text(details.discussionLabel),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

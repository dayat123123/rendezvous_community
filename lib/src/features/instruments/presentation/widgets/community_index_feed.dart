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
import 'package:rendezvous_community/src/features/instruments/domain/services/market_instrument_directory.dart';
import 'package:rendezvous_community/src/features/instruments/presentation/community_instruments.dart';
import 'package:rendezvous_community/src/features/stocks/presentation/cubit/stock_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityIndexFeed extends StatefulWidget {
  const CommunityIndexFeed({
    super.key,
    required this.indexCode,
    this.indexName,
    this.showHeader = true,
    this.showComposePrompt = true,
    this.postOpenMode = CommunityPostOpenMode.navigate,
    this.builders,
    this.scrollController,
    this.filter,
  });

  final String indexCode;
  final String? indexName;
  final bool showHeader;
  final bool showComposePrompt;
  final CommunityPostOpenMode postOpenMode;
  final CommunityFeedBuilders? builders;
  final ScrollController? scrollController;
  final String? filter;

  @override
  State<CommunityIndexFeed> createState() => _CommunityIndexFeedState();
}

class _CommunityIndexFeedState extends State<CommunityIndexFeed> {
  MarketInstrumentDirectory? _instruments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final instruments = CommunityInstruments.maybeOf(context);
    if (identical(instruments, _instruments)) return;
    _instruments?.removeListener(_changed);
    _instruments = instruments?..addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _instruments?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final code = _instruments?.canonicalOr(widget.indexCode) ?? widget.indexCode.trim().toUpperCase();
    return withFeedBuilders(
      context,
      widget.builders,
      BlocProvider(
        key: ValueKey(code),
        create: (_) => StockCubit(stocks: deps.stocks, chat: deps.chat, code: code)..load(),
        child: BlocListener<StockCubit, StockState>(
          listenWhen: (a, b) => a.errorId != b.errorId,
          listener: (context, state) => showCommunityError(context, state.error!),
          child: CommunityFeedList(
            scope: FeedScope.stock(code),
            postOpenMode: widget.postOpenMode,
            scrollController: widget.scrollController,
            filter: widget.filter,
            emptyMessage: context.communityL10n.indexFeedEmpty(code),
            header: Column(
              children: [
                if (widget.showHeader) _IndexHeader(code: code, name: widget.indexName, instruments: _instruments),
                if (widget.showComposePrompt) CommunityComposePromptCard(initialStock: code),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexHeader extends StatelessWidget {
  const _IndexHeader({required this.code, this.name, this.instruments});

  final String code;
  final String? name;
  final MarketInstrumentDirectory? instruments;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final instrument = instruments?.find(code);
    final info = CommunityScope.of(context).callbacks.stockInfo?.call(code);
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, state) {
        final cubit = context.read<StockCubit>();
        final stock = state.stock;
        final title = name ?? instrument?.name ?? info?.name ?? code;
        final roomEnabled = instrument?.roomEnabled ?? true;
        final aliases = instrument?.aliases ?? const <String>[];
        final details = CommunityIndexHeaderDetails(
          code: code,
          name: title,
          kindLabel: l10n.indexLabel,
          instrument: instrument,
          description: instrument?.description,
          aliases: aliases,
          aliasesLabel: aliases.isEmpty ? null : l10n.indexAliases(aliases.map((a) => '\$$a').join(', ')),
          subtitle: stock != null
              ? [?info?.price, l10n.watchers(stock.watcherCount)].join(' · ')
              : state.loaded
              ? l10n.stockNotFound
              : null,
          found: stock != null,
          loaded: state.loaded,
          watching: state.watching,
          joining: state.joining,
          roomEnabled: roomEnabled,
          watchLabel: state.watching ? l10n.watching : l10n.watch,
          discussionLabel: l10n.stockDiscussion,
          roomClosedLabel: l10n.indexRoomClosed,
          onToggleWatch: stock == null ? null : cubit.toggleWatch,
          onOpenDiscussion: stock == null || state.joining || !roomEnabled
              ? null
              : () async {
                  final roomId = await cubit.joinDiscussion();
                  if (roomId != null && context.mounted) CommunityNavigator.openRoom(context, roomId);
                },
        );
        return buildFeedPart((b) => b.indexHeader, context, details, _DefaultIndexHeader(details: details));
      },
    );
  }
}

class _DefaultIndexHeader extends StatelessWidget {
  const _DefaultIndexHeader({required this.details});

  final CommunityIndexHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final subtitle = details.subtitle;
    final description = details.description;
    final aliases = details.aliasesLabel;
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
                child: Icon(Icons.insights, color: style.accent),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: spacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('\$${details.code}', style: style.typography.title.copyWith(fontSize: 20)),
                        DecoratedBox(
                          decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.badgeRadius),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
                            child: Text(
                              details.kindLabel,
                              style: style.typography.badge.copyWith(color: style.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (details.name != details.code)
                      Text(details.name, style: style.typography.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (subtitle != null)
                      Text(subtitle, style: style.typography.meta, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Text(description, style: style.typography.body),
          ],
          if (aliases != null) ...[SizedBox(height: spacing.xs), Text(aliases, style: style.typography.meta)],
          if (details.found) ...[
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
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
                OutlinedButton.icon(
                  style: style.secondaryButtonStyle(),
                  onPressed: details.onOpenDiscussion,
                  icon: Icon(details.roomEnabled ? Icons.forum_outlined : Icons.lock_outline, size: 18),
                  label: Text(details.roomEnabled ? details.discussionLabel : details.roomClosedLabel),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

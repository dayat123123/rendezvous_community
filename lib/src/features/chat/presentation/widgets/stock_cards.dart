import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/stock_card.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';

class StockCards extends StatelessWidget {
  const StockCards({super.key, required this.codes, required this.isMine});

  final List<String> codes;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final callbacks = context.getInheritedWidgetOfExactType<CommunityScope>()?.dependencies.callbacks;
    final builder = CommunityChatBuilders.of(context).stockCard;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final code in codes)
          Builder(
            builder: (context) {
              final details = CommunityStockCardDetails(
                code: code,
                isMine: isMine,
                info: callbacks?.stockInfo?.call(code),
                onTap: () => CommunityNavigator.openStock(context, code, source: 'chat'),
              );
              return buildChatPart(builder, context, details, StockCardTile(details: details));
            },
          ),
      ],
    );
  }
}

class StockCardTile extends StatelessWidget {
  const StockCardTile({super.key, required this.details});

  final CommunityStockCardDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final t = CommunityTheme.of(context);
    final info = details.info;
    final rising = info?.rising;
    final name = info?.name;
    final price = info?.price;
    final change = info?.change;
    final (changeBackground, changeForeground) = switch (rising) {
      null => (style.pill, style.textSecondary),
      true => (t.bullish, t.onBullish),
      false => (t.bearish, t.onBearish),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs + spacing.xxs),
      child: Material(
        color: style.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: style.borderSide),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: details.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: style.avatarSizes.small + spacing.xs,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: style.accentMuted, borderRadius: style.radii.controlRadius),
                      child: Icon(Icons.candlestick_chart_outlined, size: 18, color: style.accent),
                    ),
                  ),
                  SizedBox(width: spacing.sm + spacing.xxs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${details.code}', style: style.typography.author),
                        if (name != null)
                          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                      ],
                    ),
                  ),
                  if (price != null || change != null) ...[
                    SizedBox(width: spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (price != null) Text(price, style: style.typography.author),
                        if (change != null)
                          Padding(
                            padding: EdgeInsets.only(top: spacing.xxs),
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: changeBackground, borderRadius: style.radii.badgeRadius),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: 1),
                                child: Text(change, style: style.typography.badge.copyWith(color: changeForeground)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<String>?> showStockCardPicker(BuildContext context) => showDialog<List<String>>(
  context: context,
  builder: (_) => carryCommunityBuilders(context)(const StockCardPicker()),
);

class StockCardPicker extends StatefulWidget {
  const StockCardPicker({super.key});

  @override
  State<StockCardPicker> createState() => _StockCardPickerState();
}

class _StockCardPickerState extends State<StockCardPicker> {
  final _controller = TextEditingController();
  final _codes = <String>[];
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _add() {
    final l10n = context.communityL10n;
    final raw = _controller.text.split(RegExp('[,;]')).where((part) => part.trim().isNotEmpty).toList();
    if (raw.isEmpty) return true;
    final codes = [for (final part in raw) normalizeStockCardCode(part)];
    if (codes.contains(null)) {
      setState(() => _error = l10n.stockCardInvalid);
      return false;
    }
    final next = <String>{..._codes, ...codes.whereType<String>()};
    if (next.length > maxStockCards) {
      setState(() => _error = l10n.stockCardLimit(maxStockCards));
      return false;
    }
    setState(() {
      _codes
        ..clear()
        ..addAll(next);
      _error = null;
      _controller.clear();
    });
    return true;
  }

  void _send() {
    if (!_add() || _codes.isEmpty) return;
    Navigator.pop(context, List<String>.of(_codes));
  }

  @override
  Widget build(BuildContext context) {
    final details = CommunityStockCardPickerDetails(
      controller: _controller,
      codes: List.unmodifiable(_codes),
      max: maxStockCards,
      onAdd: _add,
      onRemove: (code) => setState(() => _codes.remove(code)),
      onSend: _send,
      onCancel: () => Navigator.pop(context),
      error: _error,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).stockCardPicker,
      context,
      details,
      _DefaultStockCardPicker(details: details),
    );
  }
}

class _DefaultStockCardPicker extends StatelessWidget {
  const _DefaultStockCardPicker({required this.details});

  final CommunityStockCardPickerDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return AlertDialog(
      backgroundColor: style.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(style.radii.card * 2)),
      title: Text(l10n.stockCardSend, style: style.typography.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: d.controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: l10n.stockCardHint,
              errorText: d.error,
              border: OutlineInputBorder(borderRadius: style.radii.controlRadius),
              suffixIcon: IconButton(
                tooltip: l10n.stockCardAdd,
                color: style.accent,
                onPressed: d.onAdd,
                icon: const Icon(Icons.add),
              ),
            ),
            onSubmitted: (_) => d.onAdd(),
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.xs + spacing.xxs,
            runSpacing: spacing.xs + spacing.xxs,
            children: [
              for (final code in d.codes)
                InputChip(
                  label: Text('\$$code'),
                  labelStyle: style.typography.label.copyWith(color: style.onChip),
                  backgroundColor: style.chip,
                  shape: const StadiumBorder(),
                  side: style.borderSide,
                  onDeleted: () => d.onRemove(code),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: d.onCancel,
          style: TextButton.styleFrom(foregroundColor: style.textSecondary),
          child: Text(l10n.cancel),
        ),
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onSend, child: Text(l10n.composeSubmit)),
      ],
    );
  }
}

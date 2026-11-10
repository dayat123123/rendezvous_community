import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/legal/domain/entities/legal_document.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';

extension LegalDocumentText on CommunityLocalizations {
  String legalMeta(LegalDocument document) =>
      legalVersion(document.version, DateFormat.yMMMMd(localeName).format(document.effectiveAt.toLocal()));

  String legalTitles(List<LegalDocument> documents) {
    final titles = [for (final document in documents) document.title];
    if (titles.length <= 1) return titles.join();
    return '${titles.sublist(0, titles.length - 1).join(', ')} $listAnd ${titles.last}';
  }
}

class CommunityLegalDocumentReader extends StatelessWidget {
  const CommunityLegalDocumentReader({
    super.key,
    required this.document,
    this.padding = const EdgeInsets.all(16),
    this.showTitle = true,
  });

  final LegalDocument document;
  final EdgeInsetsGeometry padding;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityLegalReaderDetails(
      document: document,
      title: showTitle ? document.title : null,
      meta: l10n.legalMeta(document),
      changesLabel: l10n.legalChanges,
      padding: padding,
    );
    return buildSettingsPart((b) => b.legalReader, context, details, _DefaultLegalReader(details: details));
  }
}

class _DefaultLegalReader extends StatelessWidget {
  const _DefaultLegalReader({required this.details});

  final CommunityLegalReaderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final title = d.title;
    final changes = d.changes;
    return Scrollbar(
      child: CommunityScrollArea(
        child: SingleChildScrollView(
          padding: d.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null) Text(title, style: style.typography.title.copyWith(fontSize: 22)),
              SizedBox(height: spacing.xs),
              Text(d.meta, style: style.typography.meta),
              if (changes != null) ...[
                SizedBox(height: spacing.md),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: style.accentMuted,
                    borderRadius: style.radii.cardRadius,
                    border: Border(
                      left: BorderSide(color: style.accent, width: spacing.xs - spacing.xxs / 2),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.changesLabel, style: style.typography.label.copyWith(color: style.accent)),
                        SizedBox(height: spacing.xs),
                        Text(changes, style: style.typography.body.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: spacing.lg),
              const CommunityDivider(),
              SizedBox(height: spacing.lg),
              SelectableText(d.body, style: style.typography.body.copyWith(height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCommunityLegalDocument(BuildContext context, LegalDocument document) {
  final l10n = context.communityL10n;
  final carry = carryCommunityBuilders(context);
  if (CommunityBreakpoints.isWide(context)) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final style = CommunityStyle.of(dialogContext);
        return carry(
          Dialog(
            backgroundColor: style.surface,
            shape: communityDialogShape(style),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640, maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: CommunityLegalDocumentReader(document: document, padding: const EdgeInsets.all(24)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.close),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => carry(
        Scaffold(
          appBar: AppBar(title: Text(document.title)),
          body: SafeArea(top: false, child: CommunityLegalDocumentReader(document: document, showTitle: false)),
        ),
      ),
    ),
  );
}

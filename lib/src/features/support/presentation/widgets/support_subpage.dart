import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class SupportPanelScope extends InheritedWidget {
  const SupportPanelScope({super.key, required this.onClose, required super.child});

  final VoidCallback? onClose;

  static VoidCallback? closeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SupportPanelScope>()?.onClose;

  @override
  bool updateShouldNotify(SupportPanelScope oldWidget) => onClose != oldWidget.onClose;
}

class SupportSubpage extends StatelessWidget {
  const SupportSubpage({
    super.key,
    required this.title,
    this.subtitle,
    this.ticket,
    required this.body,
    this.downloadLabel,
    this.onDownload,
    this.downloading = false,
  });

  final String title;
  final String? subtitle;
  final SupportTicket? ticket;
  final Widget body;
  final String? downloadLabel;
  final VoidCallback? onDownload;
  final bool downloading;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final details = CommunitySupportPageHeaderDetails(
      title: title,
      subtitle: subtitle,
      ticket: ticket,
      onBack: navigator.canPop() ? () => navigator.maybePop() : null,
      onClose: SupportPanelScope.closeOf(context),
      downloadLabel: downloadLabel,
      onDownload: downloading ? null : onDownload,
      downloading: downloading,
    );
    return Scaffold(
      body: Column(
        children: [
          buildSupportPart((b) => b.pageHeader, context, details, _DefaultPageHeader(details: details)),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _DefaultPageHeader extends StatelessWidget {
  const _DefaultPageHeader({required this.details});

  final CommunitySupportPageHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final subtitle = d.subtitle;
    final onBack = d.onBack;
    final onClose = d.onClose;
    final downloadLabel = d.downloadLabel;
    return AppBar(
      automaticallyImplyLeading: false,
      leading: onBack == null ? null : BackButton(onPressed: onBack),
      title: subtitle == null
          ? Text(d.title)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
              ],
            ),
      actions: [
        if (downloadLabel != null && (d.canDownload || d.downloading))
          IconButton(
            tooltip: downloadLabel,
            onPressed: d.onDownload,
            icon: d.downloading
                ? SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: style.accent))
                : Icon(style.icons.download),
          ),
        if (onClose != null)
          IconButton(tooltip: context.communityL10n.close, onPressed: onClose, icon: const Icon(Icons.close)),
      ],
    );
  }
}

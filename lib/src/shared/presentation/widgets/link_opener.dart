import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:url_launcher/url_launcher.dart';

typedef CommunityLinkLauncher = Future<bool> Function(Uri uri);

Future<bool> _launchExternal(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

String linkDisplayDomain(Uri uri) => uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;

Future<bool> openCommunityLink(BuildContext context, Uri uri, {CommunityLinkLauncher? launcher}) async {
  final safe = safeLinkUri(uri.toString());
  if (safe == null) return false;
  final l10n = context.communityL10n;
  final builder = CommunitySharedBuilders.of(context, listen: false).linkDialog;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final domain = linkDisplayDomain(safe);
      final details = CommunityLinkConfirmDetails(
        uri: safe,
        domain: domain,
        title: l10n.linkOpenTitle,
        body: l10n.linkOpenBody(domain),
        confirmLabel: l10n.linkOpenAction,
        cancelLabel: l10n.cancel,
        onConfirm: () => Navigator.pop(dialogContext, true),
        onCancel: () => Navigator.pop(dialogContext, false),
      );
      final fallback = _LinkDialog(details: details);
      return builder == null ? fallback : builder(dialogContext, details, fallback);
    },
  );
  if (confirmed != true || !context.mounted) return false;
  final opened = await (launcher ?? _launchExternal)(safe).catchError((Object _) => false);
  if (!opened && context.mounted) showCommunityMessage(context, l10n.linkOpenFailed);
  return opened;
}

class _LinkDialog extends StatelessWidget {
  const _LinkDialog({required this.details});

  final CommunityLinkConfirmDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = CommunityStyle.of(context);
    final safe = details.uri;
    return AlertDialog(
      title: Text(details.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details.body),
          SizedBox(height: style.spacing.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(style.spacing.sm),
            decoration: BoxDecoration(
              color: style.pill,
              border: Border.fromBorderSide(style.borderSide),
              borderRadius: style.radii.controlRadius,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${safe.scheme}://'),
                  TextSpan(
                    text: safe.host,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: safe.toString().substring('${safe.scheme}://${safe.host}'.length)),
                ],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: style.textPrimary),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: details.onCancel, child: Text(details.cancelLabel)),
        FilledButton(onPressed: details.onConfirm, child: Text(details.confirmLabel)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityDisclaimer extends StatelessWidget {
  const CommunityDisclaimer({super.key, this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8)});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final details = CommunityDisclaimerDetails(text: context.communityL10n.disclaimer, padding: padding);
    return buildSharedPart((b) => b.disclaimer, context, details, _DefaultDisclaimer(details: details));
  }
}

class _DefaultDisclaimer extends StatelessWidget {
  const _DefaultDisclaimer({required this.details});

  final CommunityDisclaimerDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final meta = style.typography.meta;
    return Padding(
      padding: details.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline, size: 14, color: style.textSecondary),
          ),
          SizedBox(width: style.spacing.xs + style.spacing.xxs),
          Expanded(child: Text(details.text, style: meta.copyWith(fontSize: 12))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityDivider extends StatelessWidget {
  const CommunityDivider({super.key, this.indent = 0, this.endIndent = 0, this.height});

  final double indent;
  final double endIndent;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final details = CommunityDividerDetails(indent: indent, endIndent: endIndent, height: height);
    final style = CommunityStyle.of(context);
    return buildSharedPart(
      (b) => b.divider,
      context,
      details,
      Divider(
        height: height ?? style.borderWidth,
        thickness: style.borderWidth,
        color: style.divider,
        indent: indent,
        endIndent: endIndent,
      ),
    );
  }
}

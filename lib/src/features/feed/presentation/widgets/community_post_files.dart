import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityPostFiles extends StatelessWidget {
  const CommunityPostFiles({super.key, required this.details});

  final CommunityPostDetails details;

  @override
  Widget build(BuildContext context) {
    final files = details.post.files;
    if (files.isEmpty) return const SizedBox.shrink();
    final style = CommunityStyle.of(context);
    return buildCommunityPart(
      CommunityFeedBuilders.of(context).postFiles,
      context,
      details,
      Padding(
        padding: EdgeInsets.only(top: style.spacing.md),
        child: DocumentAttachments(attachments: files, color: style.textPrimary, card: true),
      ),
    );
  }
}

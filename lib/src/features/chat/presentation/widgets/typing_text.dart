import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

String typingText(CommunityLocalizations l10n, Iterable<UserSummary> users, {bool direct = false, int others = 0}) {
  final list = users.toList();
  if (list.isEmpty) {
    if (others <= 0) return '';
    return others == 1 ? l10n.typingSomeone : l10n.typingMany;
  }
  if (direct) return l10n.typingShort;
  return list.length == 1 && others <= 0 ? l10n.typing(list.first.name) : l10n.typingMany;
}

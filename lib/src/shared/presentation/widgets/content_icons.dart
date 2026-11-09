import 'package:flutter/material.dart';

IconData? communityContentIcon(String? key) => switch (key) {
  'account' => Icons.person_outline,
  'wallet' => Icons.account_balance_wallet_outlined,
  'receipt' => Icons.receipt_long_outlined,
  'chart' => Icons.pie_chart_outline,
  'tools' => Icons.build_outlined,
  'shield' => Icons.gpp_maybe_outlined,
  'help' => Icons.help_outline,
  'document' => Icons.description_outlined,
  'phone' => Icons.phone_outlined,
  'card' => Icons.credit_card,
  'chat' => Icons.chat_bubble_outline,
  'star' => Icons.star_outline,
  'bell' => Icons.notifications_none,
  'lock' => Icons.lock_outline,
  'globe' => Icons.public,
  'gift' => Icons.card_giftcard,
  _ => null,
};

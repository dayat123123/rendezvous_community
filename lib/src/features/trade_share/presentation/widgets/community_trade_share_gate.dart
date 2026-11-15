import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/services/community_trade_share.dart';

typedef CommunityTradeShareStatusWidgetBuilder = Widget Function(BuildContext context, TradeShareStatus? status);

class CommunityTradeShareStatusBuilder extends StatefulWidget {
  const CommunityTradeShareStatusBuilder({super.key, required this.builder});

  final CommunityTradeShareStatusWidgetBuilder builder;

  @override
  State<CommunityTradeShareStatusBuilder> createState() => _CommunityTradeShareStatusBuilderState();
}

class _CommunityTradeShareStatusBuilderState extends State<CommunityTradeShareStatusBuilder> {
  CommunityTradeShare? _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = CommunityTradeShareScope.serviceOf(context);
    if (identical(service, _service)) return;
    _service = service;
    if (service != null) unawaited(service.ensureFresh());
  }

  @override
  Widget build(BuildContext context) {
    final service = _service;
    if (service == null) return widget.builder(context, null);
    return ValueListenableBuilder<TradeShareStatus?>(
      valueListenable: service.listenable,
      builder: (context, status, _) => widget.builder(context, status),
    );
  }
}

class CommunityTradeShareGate extends StatelessWidget {
  const CommunityTradeShareGate({super.key, required this.child, this.fallback = const SizedBox.shrink()});

  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) =>
      CommunityTradeShareStatusBuilder(builder: (context, status) => status?.enabled ?? false ? child : fallback);
}

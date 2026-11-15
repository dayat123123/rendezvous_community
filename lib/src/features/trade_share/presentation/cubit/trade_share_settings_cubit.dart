import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/services/community_trade_share.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

enum TradeShareSaveResult { saved, confirmationRequired, failed }

class TradeShareDraft {
  const TradeShareDraft({
    this.accounts = const {},
    this.showPrice = true,
    this.showLot = true,
    this.delayMinutes = 15,
    this.subscribeMode = TradeSubscribeMode.auto,
    this.termsAccepted = false,
  });

  factory TradeShareDraft.from(TradeShareStatus status) {
    final limits = status.limits;
    if (status.canEdit) {
      return TradeShareDraft(
        accounts: {for (final account in status.accounts) account.custId},
        showPrice: status.showPrice,
        showLot: status.showLot,
        delayMinutes: limits.clampDelay(status.delayMinutes ?? limits.minDelayMinutes),
        subscribeMode: status.subscribeMode,
      );
    }
    return TradeShareDraft(
      accounts: {
        for (final account in status.eligibility.accounts)
          if (account.isActive) account.custId,
      },
      delayMinutes: limits.minDelayMinutes,
    );
  }

  final Set<String> accounts;
  final bool showPrice;
  final bool showLot;
  final int delayMinutes;
  final TradeSubscribeMode subscribeMode;
  final bool termsAccepted;

  TradeShareApplication toApplication() => TradeShareApplication(
    accounts: [...accounts]..sort(),
    showPrice: showPrice,
    showLot: showLot,
    delayMinutes: delayMinutes,
    subscribeMode: subscribeMode,
  );

  TradeShareDraft copyWith({
    Set<String>? accounts,
    bool? showPrice,
    bool? showLot,
    int? delayMinutes,
    TradeSubscribeMode? subscribeMode,
    bool? termsAccepted,
  }) => TradeShareDraft(
    accounts: accounts ?? this.accounts,
    showPrice: showPrice ?? this.showPrice,
    showLot: showLot ?? this.showLot,
    delayMinutes: delayMinutes ?? this.delayMinutes,
    subscribeMode: subscribeMode ?? this.subscribeMode,
    termsAccepted: termsAccepted ?? this.termsAccepted,
  );
}

class TradeShareSettingsState {
  const TradeShareSettingsState({
    this.status = LoadStatus.initial,
    this.data,
    this.draft = const TradeShareDraft(),
    this.busy = false,
    this.error,
    this.actionError,
    this.actionErrorId = 0,
  });

  final LoadStatus status;
  final TradeShareStatus? data;
  final TradeShareDraft draft;
  final bool busy;
  final Object? error;
  final Object? actionError;
  final int actionErrorId;

  bool get canSubmit {
    final current = data;
    if (current == null || !current.canApply || busy) return false;
    return current.eligibility.eligible &&
        current.eligibility.termsDocument != null &&
        draft.accounts.isNotEmpty &&
        draft.termsAccepted;
  }

  bool get canSave {
    final current = data;
    return current != null && current.canEdit && !busy && draft.accounts.isNotEmpty;
  }

  TradeShareSettingsState copyWith({
    LoadStatus? status,
    TradeShareStatus? data,
    TradeShareDraft? draft,
    bool? busy,
    Object? Function()? error,
    Object? actionError,
    int? actionErrorId,
  }) => TradeShareSettingsState(
    status: status ?? this.status,
    data: data ?? this.data,
    draft: draft ?? this.draft,
    busy: busy ?? this.busy,
    error: error == null ? this.error : error(),
    actionError: actionError ?? this.actionError,
    actionErrorId: actionErrorId ?? this.actionErrorId,
  );
}

class TradeShareSettingsCubit extends Cubit<TradeShareSettingsState> {
  TradeShareSettingsCubit(this._service) : super(const TradeShareSettingsState());

  final CommunityTradeShare _service;

  Future<void> load({bool refresh = true}) async {
    if (state.data == null) emit(state.copyWith(status: LoadStatus.loading, error: () => null));
    try {
      final status = await _service.status(refresh: refresh);
      if (!isClosed) _show(status);
    } catch (e) {
      if (isClosed) return;
      if (state.data == null) {
        emit(state.copyWith(status: LoadStatus.failure, error: () => e));
      } else {
        _fail(e);
      }
    }
  }

  void _show(TradeShareStatus status) =>
      emit(state.copyWith(status: LoadStatus.ready, data: status, draft: TradeShareDraft.from(status), busy: false));

  void toggleAccount(String custId, {required bool selected}) {
    final accounts = {...state.draft.accounts};
    selected ? accounts.add(custId) : accounts.remove(custId);
    emit(state.copyWith(draft: state.draft.copyWith(accounts: accounts)));
  }

  void setShowPrice(bool value) => emit(state.copyWith(draft: state.draft.copyWith(showPrice: value)));

  void setShowLot(bool value) => emit(state.copyWith(draft: state.draft.copyWith(showLot: value)));

  void setDelay(int minutes) {
    final limits = state.data?.limits ?? const TradeShareLimits();
    emit(state.copyWith(draft: state.draft.copyWith(delayMinutes: limits.clampDelay(minutes))));
  }

  void setSubscribeMode(TradeSubscribeMode mode) =>
      emit(state.copyWith(draft: state.draft.copyWith(subscribeMode: mode)));

  void setTermsAccepted(bool value) => emit(state.copyWith(draft: state.draft.copyWith(termsAccepted: value)));

  Future<bool> submit() async {
    final terms = state.data?.eligibility.termsDocument;
    if (!state.canSubmit || terms == null) return false;
    return _run(() => _service.repository.apply(state.draft.toApplication(), termsDocumentId: terms.id));
  }

  Future<TradeShareSaveResult> save({bool confirm = false}) async {
    if (!state.canSave) return TradeShareSaveResult.failed;
    emit(state.copyWith(busy: true));
    try {
      final status = await _service.repository.updateSettings(state.draft.toApplication(), confirm: confirm);
      _service.accept(status);
      if (!isClosed) _show(status);
      return TradeShareSaveResult.saved;
    } catch (e) {
      if (isClosed) return TradeShareSaveResult.failed;
      if (!confirm && mapError(e).code == 'confirmation_required') {
        emit(state.copyWith(busy: false));
        return TradeShareSaveResult.confirmationRequired;
      }
      _fail(e);
      return TradeShareSaveResult.failed;
    }
  }

  Future<bool> pause() => _run(_service.repository.pause);

  Future<bool> resume() => _run(_service.repository.resume);

  Future<bool> withdraw() => _run(_service.repository.withdraw);

  Future<bool> _run(Future<TradeShareStatus> Function() action) async {
    if (state.busy) return false;
    emit(state.copyWith(busy: true));
    try {
      final status = await action();
      _service.accept(status);
      if (!isClosed) _show(status);
      return true;
    } catch (e) {
      if (isClosed) return false;
      _fail(e);
      final code = mapError(e).code;
      if (code == 'terms_outdated' || code == 'not_eligible' || code == 'already_applied') await load();
      return false;
    }
  }

  void _fail(Object error) {
    if (!isClosed) emit(state.copyWith(busy: false, actionError: error, actionErrorId: state.actionErrorId + 1));
  }
}

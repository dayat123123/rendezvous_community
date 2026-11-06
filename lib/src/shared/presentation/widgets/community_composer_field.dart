import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart';
import 'package:rendezvous_community/src/features/stocks/domain/entities/stock_suggestion.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';

class CommunityComposerField extends StatefulWidget {
  const CommunityComposerField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSubmit,
    this.focusNode,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 6,
    this.enabled = true,
    this.autofocus = false,
    this.enableAutocomplete = true,
    this.decoration,
    this.style,
    this.onPaste,
    this.onContentInserted,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSubmit;
  final FocusNode? focusNode;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final bool autofocus;
  final bool enableAutocomplete;
  final InputDecoration? decoration;
  final TextStyle? style;
  final Future<bool> Function()? onPaste;
  final ValueChanged<Uint8List>? onContentInserted;

  @override
  State<CommunityComposerField> createState() => _CommunityComposerFieldState();
}

sealed class _Suggestion {
  const _Suggestion();
}

class _StockSuggestion extends _Suggestion {
  const _StockSuggestion(this.stock);
  final StockSuggestion stock;
}

class _UserSuggestion extends _Suggestion {
  const _UserSuggestion(this.user);
  final UserSummary user;
}

ThemeData _standardDensity(ThemeData theme) =>
    theme.visualDensity == VisualDensity.standard ? theme : theme.copyWith(visualDensity: VisualDensity.standard);

class _CommunityComposerFieldState extends State<CommunityComposerField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  Timer? _debounce;
  ActiveToken? _token;
  List<_Suggestion> _suggestions = const [];
  int _highlight = 0;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _onKey;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    if (widget.onPaste != null && event is KeyDownEvent && _isPaste(key)) {
      unawaited(_paste());
      return KeyEventResult.handled;
    }

    if (_suggestions.isNotEmpty) {
      if (key == LogicalKeyboardKey.arrowDown) {
        setState(() => _highlight = (_highlight + 1) % _suggestions.length);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowUp) {
        setState(() => _highlight = (_highlight - 1 + _suggestions.length) % _suggestions.length);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.escape) {
        _clearSuggestions();
        return KeyEventResult.handled;
      }
      if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.tab) && !shift) {
        _apply(_suggestions[_highlight]);
        return KeyEventResult.handled;
      }
    }

    final isEnter = key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter;
    if (isEnter && !shift && event is KeyDownEvent && widget.onSubmit != null && isDesktopPlatform(context)) {
      widget.onSubmit!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _isPaste(LogicalKeyboardKey key) {
    if (key != LogicalKeyboardKey.keyV) return false;
    final keyboard = HardwareKeyboard.instance;
    final apple = defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;
    return apple ? keyboard.isMetaPressed : keyboard.isControlPressed;
  }

  Future<void> _paste() async {
    if (await widget.onPaste!() || !mounted) return;
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text == null || text.isEmpty || !mounted) return;
    final value = widget.controller.value;
    final selection = value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
    var insert = text;
    final max = widget.maxLength;
    if (max != null) {
      final room = max - (value.text.length - (selection.end - selection.start));
      if (room <= 0) return;
      if (insert.length > room) insert = insert.substring(0, room);
    }
    widget.controller.value = value.replaced(selection, insert);
  }

  void _onTextChanged() {
    if (!widget.enableAutocomplete) return;
    final value = widget.controller.value;
    final token = value.selection.isCollapsed ? findActiveToken(value.text, value.selection.baseOffset) : null;
    if (token == null || token.query.isEmpty) {
      _clearSuggestions();
      return;
    }
    if (token.trigger == _token?.trigger && token.query == _token?.query) return;
    _token = token;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(token));
  }

  Future<void> _search(ActiveToken token) async {
    final deps = CommunityScope.of(context);
    final id = ++_requestId;
    try {
      final List<_Suggestion> results = token.trigger == r'$'
          ? [
              for (final s in (await deps.callbacks.stockSearch?.call(token.query) ?? const <StockSuggestion>[]).take(
                6,
              ))
                _StockSuggestion(s),
            ]
          : [for (final u in await deps.profiles.searchUsers(token.query, limit: 6)) _UserSuggestion(u)];
      if (!mounted || id != _requestId) return;
      setState(() {
        _suggestions = results;
        _highlight = 0;
      });
    } catch (_) {}
  }

  void _clearSuggestions() {
    _debounce?.cancel();
    _token = null;
    _requestId++;
    if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
  }

  void _apply(_Suggestion suggestion) {
    final token = _token;
    if (token == null) return;
    final insert = switch (suggestion) {
      _StockSuggestion(:final stock) => '\$${stock.code} ',
      _UserSuggestion(:final user) => '@${user.username} ',
    };
    final text = widget.controller.text;
    final updated = text.replaceRange(token.start, token.end, insert);
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: token.start + insert.length),
    );
    _clearSuggestions();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_suggestions.isNotEmpty)
          Material(
            shape: RoundedRectangleBorder(borderRadius: style.radii.cardRadius, side: style.borderSide),
            color: style.surface,
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                addAutomaticKeepAlives: false,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: style.spacing.xs),
                itemCount: _suggestions.length,
                itemBuilder: (context, i) {
                  final s = _suggestions[i];
                  final details = CommunityComposerSuggestionDetails(
                    kind: switch (s) {
                      _StockSuggestion() => CommunitySuggestionKind.stock,
                      _UserSuggestion() => CommunitySuggestionKind.user,
                    },
                    title: switch (s) {
                      _StockSuggestion(:final stock) => '\$${stock.code}',
                      _UserSuggestion(:final user) => user.name,
                    },
                    subtitle: switch (s) {
                      _StockSuggestion(:final stock) => stock.name,
                      _UserSuggestion(:final user) => '@${user.username}',
                    },
                    leading: switch (s) {
                      _StockSuggestion() => Icon(Icons.show_chart, color: style.textSecondary),
                      _UserSuggestion(:final user) => CommunityAvatar(user: user, radius: 14),
                    },
                    highlighted: i == _highlight,
                    onSelect: () => _apply(s),
                  );
                  return buildSharedPart(
                    (b) => b.composerSuggestion,
                    context,
                    details,
                    _DefaultSuggestion(details: details),
                  );
                },
              ),
            ),
          ),
        Theme(
          data: _standardDensity(Theme.of(context)),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            style: widget.style,
            decoration: (widget.decoration ?? const InputDecoration()).copyWith(hintText: widget.hintText),
            contentInsertionConfiguration: widget.onContentInserted == null
                ? null
                : ContentInsertionConfiguration(
                    allowedMimeTypes: const ['image/png', 'image/jpeg', 'image/gif', 'image/webp'],
                    onContentInserted: (content) {
                      final data = content.data;
                      if (data != null && data.isNotEmpty) widget.onContentInserted!(data);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _DefaultSuggestion extends StatelessWidget {
  const _DefaultSuggestion({required this.details});

  final CommunityComposerSuggestionDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final subtitle = details.subtitle;
    return ListTile(
      dense: true,
      selected: details.highlighted,
      selectedTileColor: style.accentMuted,
      leading: details.leading,
      title: Text(details.title, style: style.typography.author.copyWith(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
      onTap: details.onSelect,
    );
  }
}

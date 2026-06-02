import 'package:flutter/material.dart';

import '../theme/police_colors.dart';

/// TextField odaktayken Türkçe karakter eklemek için uygulama geneli yardımcı.
///
/// Bazı emülatör/klavye düzenlerinde ş, ı, ç gibi harfler fiziksel klavyeden
/// gelmeyebiliyor. Bu çubuk aktif metin alanına karakteri doğrudan ekler.
class TurkishInputAccessory extends StatefulWidget {
  const TurkishInputAccessory({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TurkishInputAccessory> createState() => _TurkishInputAccessoryState();
}

class _TurkishInputAccessoryState extends State<TurkishInputAccessory>
    with WidgetsBindingObserver {
  static const _letters = [
    'ç',
    'ğ',
    'ı',
    'ö',
    'ş',
    'ü',
    'Ç',
    'Ğ',
    'İ',
    'Ö',
    'Ş',
    'Ü'
  ];

  bool _hasEditableFocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_syncFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFocus());
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_syncFocus);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFocus());
  }

  void _syncFocus() {
    final editable = _focusedEditable();
    final next = editable != null;
    if (next == _hasEditableFocus || !mounted) return;
    setState(() => _hasEditableFocus = next);
  }

  EditableTextState? _focusedEditable() {
    final context = FocusManager.instance.primaryFocus?.context;
    return context?.findAncestorStateOfType<EditableTextState>();
  }

  void _insert(String letter) {
    final editable = _focusedEditable();
    if (editable == null) return;

    final controller = editable.widget.controller;
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final safeStart = start.clamp(0, text.length);
    final safeEnd = end.clamp(0, text.length);
    final insertAt = safeStart < safeEnd ? safeStart : safeEnd;
    final replaceEnd = safeStart < safeEnd ? safeEnd : safeStart;
    final nextText = text.replaceRange(insertAt, replaceEnd, letter);
    final cursor = insertAt + letter.length;
    final nextValue = value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: cursor),
      composing: TextRange.empty,
    );

    controller.value = nextValue;
    editable.widget.onChanged?.call(nextText);
    editable.widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottom = mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : 0.0;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          child: IgnorePointer(
            ignoring: !_hasEditableFocus,
            child: AnimatedOpacity(
              opacity: _hasEditableFocus ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: SafeArea(
                top: false,
                child: Material(
                  color: PoliceColors.surfaceDark.withValues(alpha: 0.98),
                  elevation: 10,
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final letter = _letters[index];
                        return _LetterButton(
                          letter: letter,
                          onTap: () => _insert(letter),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemCount: _letters.length,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LetterButton extends StatelessWidget {
  const _LetterButton({
    required this.letter,
    required this.onTap,
  });

  final String letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PoliceColors.primaryBlue.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: PoliceColors.primaryBlue.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            color: PoliceColors.titleOnDark,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

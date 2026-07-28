import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final String? suffix;

  const AppInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.prefix,
    this.suffix,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return widget.prefix != null
        ? _buildPrefixRow(context, isDark)
        : _buildPlainField(context, isDark);
  }

  // ── Rs. prefix: grey badge left | text field right ───────────────────────
  Widget _buildPrefixRow(BuildContext context, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1224) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused
              ? AppColors.blue
              : isDark
                  ? const Color(0xFF1E2A45)
                  : const Color(0xFFDDE3F4),
          width: _focused ? 2.0 : 1.5,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))]
            : null,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161F38) : const Color(0xFFF0F3FF),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
            border: Border(
              right: BorderSide(
                color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFDDE3F4),
                width: 1.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.prefix!,
            style: TextStyle(
              color: context.cText3,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: context.cHint, fontSize: 13),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Plain field with optional suffix (%) ─────────────────────────────────
  Widget _buildPlainField(BuildContext context, bool isDark) {
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: context.cHint, fontSize: 13),
        suffixText: widget.suffix,
        suffixStyle: TextStyle(color: context.cText3, fontSize: 15, fontWeight: FontWeight.w600),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        filled: true,
        fillColor: isDark ? const Color(0xFF0C1224) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFDDE3F4), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF1E2A45) : const Color(0xFFDDE3F4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
    );
  }
}

// ── DateField (kept for other screens) ───────────────────────────────────────
class DateField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const DateField({super.key, required this.controller, required this.label, required this.hint});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label,
          style: TextStyle(
            color: _focused ? AppColors.blue : context.cText4,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          )),
      const SizedBox(height: 6),
      TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: TextStyle(color: context.cText1, fontSize: 15, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: context.cHint, fontSize: 13),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          filled: true,
          fillColor: isDark ? const Color(0xFF0C1224) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.cBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.blue, width: 2)),
        ),
      ),
    ]);
  }
}

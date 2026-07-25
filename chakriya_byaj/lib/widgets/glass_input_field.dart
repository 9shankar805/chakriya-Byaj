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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _focused
            ? [BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )]
            : context.cardShadow,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: context.cText1,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: context.cHint, fontSize: 15, fontWeight: FontWeight.w400),
          prefixText: widget.prefix != null ? '${widget.prefix}  ' : null,
          prefixStyle: TextStyle(color: context.cText3, fontSize: 16, fontWeight: FontWeight.w600),
          suffixText: widget.suffix,
          suffixStyle: const TextStyle(color: AppColors.amber, fontSize: 16, fontWeight: FontWeight.w700),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          filled: true,
          fillColor: context.cSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.cBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.cBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blue, width: 2),
          ),
        ),
      ),
    );
  }
}

// ── Date field ────────────────────────────────────────────────────────────────
class DateField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const DateField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
  });

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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
                widget.label,
                style: TextStyle(
                  color: _focused ? AppColors.blue : context.cText4,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      const SizedBox(height: 6),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _focused
              ? [BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )]
              : context.cardShadow,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.cText1,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: context.cHint, fontSize: 15),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            filled: true,
            fillColor: context.cSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.cBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.cBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.blue, width: 2),
            ),
          ),
        ),
      ),
    ]);
  }
}

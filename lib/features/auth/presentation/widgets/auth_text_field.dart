import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final int? maxLength;
  final Widget? suffixWidget;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.readOnly = false,
    this.maxLength,
    this.suffixWidget,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isObscured = true;
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Label ────────────────────────────────
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: _isFocused
                ? AppColors.primary
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
        const SizedBox(height: 8),

        // ─── Field ────────────────────────────────
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText && _isObscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          readOnly: widget.readOnly,
          maxLength: widget.maxLength,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight),
                        size: 20,
                      ),
                      child: widget.prefixIcon!,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.obscureText
                ? _buildPasswordToggle(isDark)
                : (widget.suffixWidget != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: widget.suffixWidget,
                      )
                    : null),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: isDark ? AppColors.cardSecondaryDark : AppColors.cardLight,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 0 : 20,
              vertical: 16,
            ),
            border: _border(AppColors.borderLight, isDark),
            enabledBorder: _border(
              isDark ? AppColors.borderDark : AppColors.borderLight,
              isDark,
            ),
            focusedBorder: _border(AppColors.primary, isDark, width: 2),
            errorBorder: _border(AppColors.danger, isDark),
            focusedErrorBorder: _border(AppColors.danger, isDark, width: 2),
            errorStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordToggle(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isObscured = !_isObscured),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, bool isDark, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

// ─── Password Strength Indicator ──────────────────────────
class PasswordStrengthIndicator extends StatelessWidget {
  final double strength; // 0.0 – 1.0
  final String label;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.label,
  });

  Color get _color {
    if (strength <= 0.25) return AppColors.danger;
    if (strength <= 0.5) return AppColors.warning;
    if (strength <= 0.75) return const Color(0xFF84CC16);
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation(_color),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Gender Selector ──────────────────────────────────────
class GenderSelector extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;

  const GenderSelector({super.key, required this.selected, required this.onSelect});

  static const _options = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: _options.map((g) {
        final isSelected = selected == g;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.cardSecondaryDark : AppColors.cardLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                g,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

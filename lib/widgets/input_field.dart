import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emprestimos_app/core/theme/theme.dart';

class InputCustomizado extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final String hint;
  final bool readOnly;
  final bool enabled;
  final double fontSize;
  final bool fieldMandatory;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool showToggleVisibility;
  final Widget? leadingIcon;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;
  final VoidCallback? onTap;

  const InputCustomizado({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscure = false,
    this.autofocus = false,
    this.type = TextInputType.text,
    this.hint = "",
    this.readOnly = false,
    this.enabled = true,
    this.fontSize = 16,
    this.fieldMandatory = false,
    this.maxLines = 1,
    this.showToggleVisibility = false,
    this.leadingIcon,
    this.inputFormatters,
    this.autofillHints,
    this.onTap,
  });

  @override
  _InputCustomizadoState createState() => _InputCustomizadoState();
}

class _InputCustomizadoState extends State<InputCustomizado> {
  bool _showPassword = false;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme; // Obtém o tema de input

    return TextFormField(
      controller: widget.controller,
      obscureText: !_showPassword && widget.obscure,
      autofocus: widget.autofocus,
      validator: widget.validator,
      keyboardType: widget.type,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      focusNode: _focusNode,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: widget.fontSize,
      ),
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      onEditingComplete: () => TextInput.finishAutofillContext(),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          fontSize: 14, // 🔹 Reduzindo o tamanho da label
          fontWeight: FontWeight.w500, // 🔹 Mantendo um peso intermediário
          color: inputTheme.labelStyle?.color ??
              Colors.grey.shade600, // 🔹 Mantendo cor do tema
        ),
        hintText: widget.hint,
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor,

        // Ajustando as bordas do input para seguir o tema global
        border: inputTheme.border,
        enabledBorder: inputTheme.enabledBorder,
        focusedBorder: inputTheme.focusedBorder,
        errorBorder: inputTheme.errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),

        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: widget.fontSize - 2,
        ),
        prefixIcon: widget.leadingIcon,
        suffixIcon: widget.showToggleVisibility
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.primaryColor,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
    );
  }
}

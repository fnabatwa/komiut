import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  /// Text field label (e.g., "Email", "Password")
  final String label;

  /// Hint text shown inside field when empty
  final String? hint;

  /// Controller to manage the text value
  final TextEditingController controller;

  /// Icon shown at the start of the field
  final IconData? prefixIcon;

  /// Whether this is a password field (hides text)
  final bool isPassword;

  /// Keyboard type (email, number, text, etc.)
  final TextInputType keyboardType;

  /// Validation function - returns error message if invalid, null if valid
  final String? Function(String?)? validator;

  /// Called when text changes
  final Function(String)? onChanged;

  /// Whether field is enabled or disabled
  final bool enabled;

  /// Maximum number of lines
  final int maxLines;

  /// Maximum length of text
  final int? maxLength;

  /// List of input formatters
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme to ensure icon colors are reactive
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,


      style: TextStyle(
        color: theme.colorScheme.onSurface,
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,

        //Prefix icon color reacts to light/dark mode
        prefixIcon: widget.prefixIcon != null
            ? Icon(
          widget.prefixIcon,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        )
            : null,

        // Suffix icon toggle
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,

            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,

        counterText: widget.maxLength != null ? '' : null,
      ),
    );
  }
}
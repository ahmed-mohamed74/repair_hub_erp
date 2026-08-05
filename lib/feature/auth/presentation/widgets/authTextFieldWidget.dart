import 'package:flutter/material.dart';

class AuthTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscureText;
  final IconData icon;
  final bool hasPostIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AuthTextFieldWidget({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    required this.icon,
    this.hasPostIcon = false,
    this.validator,
    this.keyboardType,
  });

  @override
  State<AuthTextFieldWidget> createState() => _AuthTextFieldWidgetState();
}

class _AuthTextFieldWidgetState extends State<AuthTextFieldWidget> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      style: theme.textTheme.titleSmall,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '${widget.hintText} is missing!';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: theme.textTheme.labelSmall,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.hasPostIcon
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
    );
  }
}

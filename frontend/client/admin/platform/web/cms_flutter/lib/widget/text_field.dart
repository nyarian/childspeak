import 'package:flutter/material.dart';

class ColoredTextFormField extends StatelessWidget {
  final TextEditingController _controller;
  final FormFieldValidator<String> _validator;
  final String _labelText;
  final String _hintText;
  final TextInputType _keyboardType;
  final bool _obscureText;
  final Color _hintTextColor;
  final bool autoFocus;

  ColoredTextFormField({
    @required TextEditingController controller,
    Key key,
    FormFieldValidator<String> validator,
    String labelText,
    String hintText,
    TextInputType keyboardType,
    bool obscureText = false,
    Color hintTextColor,
    this.autoFocus = false,
  })  : _controller = controller,
        _validator = validator ?? ((_) => null),
        _labelText = labelText,
        _hintText = hintText,
        _keyboardType = keyboardType,
        _obscureText = obscureText,
        _hintTextColor = hintTextColor ?? Colors.grey[300],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextFormField(
      controller: _controller,
      validator: _validator,
      keyboardType: _keyboardType,
      obscureText: _obscureText,
      autofocus: autoFocus,
      decoration: InputDecoration(
        labelText: _labelText,
        hintText: _hintText,
        labelStyle: TextStyle(color: theme.primaryColorLight),
        hintStyle: TextStyle(color: _hintTextColor),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColor)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColorLight)),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColorDark)),
        errorBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }
}

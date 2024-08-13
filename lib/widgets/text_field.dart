import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String labelText;
  final Widget? helperText;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? initialValue;
  final bool? errorText;

  const TextFieldWidget(
      {Key? key,
      required this.labelText,
      this.helperText,
      required this.onChanged,
       this.validator, this.focusNode, this.initialValue, this.errorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10),child: TextFormField(
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: InputDecoration(
        icon: const Icon(Icons.email),
        helperText: 'A complete, valid email e.g. joe@gmail.com',
        errorText: errorText!
            ? 'Please ensure the email entered is valid'
            : null,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
    ));
  }
}

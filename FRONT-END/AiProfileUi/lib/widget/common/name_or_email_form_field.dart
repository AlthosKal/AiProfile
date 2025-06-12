import 'package:flutter/material.dart';

import 'custom_form_field.dart';

class NameOrEmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const NameOrEmailFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Nombre o correo',
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo requerido';
        }
        if (!value.contains('@') &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value) &&
            value.trim().length < 3) {
          return 'Ingrese un nombre o correo electrónico válido';
        }
        return null;
      },
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

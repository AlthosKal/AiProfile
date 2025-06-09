import 'package:flutter/material.dart';

import 'custom_form_field.dart'; // Asegúrate de tener el import correcto

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onFieldSubmitted;

  const EmailFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      controller: controller,
      focusNode: focusNode,
      labelText: 'Correo electrónico',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo requerido';
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value.trim()))
          return 'Ingrese correo electrónico válido';
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../core/constant/app_constant.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Buscar...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppConstants.paddingHorizontalMedium,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              showClearButton && controller?.text.isNotEmpty == true
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller?.clear();
                      onClear?.call();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}

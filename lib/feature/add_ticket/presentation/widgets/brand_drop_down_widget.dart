import 'package:flutter/material.dart';

class BrandDropdown extends StatelessWidget {
  final String currentBrand;
  final ValueChanged<String?>? onChanged;

  const BrandDropdown({super.key, required this.currentBrand, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Brand',
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentBrand,
          isExpanded: true,
          items: [
            'Apple',
            'Samsung',
            'Google',
            'Xiaomi',
            'Oppo',
          ].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

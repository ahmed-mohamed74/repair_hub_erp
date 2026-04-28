import 'dart:io';

import 'package:flutter/material.dart';

class PhotoSlot extends StatelessWidget {
  final String path;
  final bool isPrimary;
  final VoidCallback onTap;

  const PhotoSlot({super.key, 
    required this.path,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: path.isNotEmpty
              ? null
              : (isPrimary
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest),
          borderRadius: BorderRadius.circular(16),
          image: path.isNotEmpty
              ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
              : null,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: path.isEmpty
            ? Icon(
                isPrimary ? Icons.add_a_photo_outlined : Icons.upload_outlined,
                color: scheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}

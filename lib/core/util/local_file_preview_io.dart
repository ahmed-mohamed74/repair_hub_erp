import 'dart:io';

import 'package:flutter/material.dart';

Widget buildLocalPhotoThumb(String path, {double size = 96}) {
  if (path.isEmpty) {
    return const SizedBox.shrink();
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.file(
      File(path),
      width: size,
      height: size,
      fit: BoxFit.cover,
    ),
  );
}

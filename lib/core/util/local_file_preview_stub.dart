import 'package:flutter/material.dart';

Widget buildLocalPhotoThumb(String path, {double size = 96}) {
  if (path.isEmpty) {
    return const SizedBox.shrink();
  }
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black12,
    ),
    child: const Icon(Icons.photo_outlined),
  );
}

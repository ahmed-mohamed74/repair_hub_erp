import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// What the user chose for a photo slot.
enum PhotoSlotChoice {
  camera,
  gallery,
  remove,
}

Future<PhotoSlotChoice?> showPhotoSlotActions(
  BuildContext context, {
  required bool hasExistingPhoto,
}) {
  return showModalBottomSheet<PhotoSlotChoice>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take photo'),
            onTap: () => Navigator.pop(ctx, PhotoSlotChoice.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, PhotoSlotChoice.gallery),
          ),
          if (hasExistingPhoto)
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(ctx).colorScheme.error),
              title: Text(
                'Remove photo',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () => Navigator.pop(ctx, PhotoSlotChoice.remove),
            ),
        ],
      ),
    ),
  );
}

ImageSource? choiceToSource(PhotoSlotChoice? c) {
  return switch (c) {
    PhotoSlotChoice.camera => ImageSource.camera,
    PhotoSlotChoice.gallery => ImageSource.gallery,
    _ => null,
  };
}

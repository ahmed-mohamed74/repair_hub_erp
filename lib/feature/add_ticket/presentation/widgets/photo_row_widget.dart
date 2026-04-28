import 'package:flutter/material.dart';
import 'package:repair_hub/feature/add_ticket/presentation/widgets/photo_slot_widget.dart';

class PhotoRow extends StatelessWidget {
  final List<String> photoPaths;
  final Function(int) onSlotTap;

  const PhotoRow({super.key, required this.photoPaths, required this.onSlotTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PhotoSlot(
            path: photoPaths[index],
            isPrimary: index == 0,
            onTap: () => onSlotTap(index),
          ),
        ),
      ),
    );
  }
}


import 'dart:io';
import 'package:flutter/material.dart';

import '../extensions/app_extensions.dart';
import '../theme/app_theme.dart';


class ScannedImagePreview extends StatelessWidget {
  final String imagePath;
  final double height;

  const ScannedImagePreview({
    super.key,
    required this.imagePath,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_rounded, size: 48, color: AppTheme.textSecondary),
            ),
          ),
          // Subtle overlay label
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_rounded, color: Colors.white, size: 12),
                  addHorizontalSpace(4),
                  Text(
                    'Scanned Image',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

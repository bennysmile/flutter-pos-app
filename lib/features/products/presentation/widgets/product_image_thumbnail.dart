import 'dart:io';

import 'package:flutter/material.dart';

class ProductImageThumbnail extends StatelessWidget {
  const ProductImageThumbnail({
    super.key,
    required this.imagePath,
    this.size = 56,
    this.iconSize = 26,
  });

  final String? imagePath;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: path == null || path.isEmpty || !File(path).existsSync()
            ? _Placeholder(iconSize: iconSize)
            : Image.file(
                File(path),
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: (size * 2).round(),
                errorBuilder: (_, _, _) => _Placeholder(iconSize: iconSize),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: iconSize,
      ),
    );
  }
}

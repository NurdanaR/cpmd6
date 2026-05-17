import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cached network image with placeholder and error fallback.
class ExerciseNetworkImage extends StatelessWidget {
  const ExerciseNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => Container(
        height: height,
        color: Colors.grey.shade300,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        color: Colors.grey.shade400,
        child: const Icon(Icons.fitness_center, size: 48),
      ),
    );
  }
}

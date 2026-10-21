import 'package:flutter/material.dart';

/// Renders Kenny Cube Pet images seamlessly from local assets or fallback URLs.
class CubePetImage extends StatelessWidget {
  const CubePetImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.isSilhouette = false,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isSilhouette;

  static const String defaultPetAsset = 'assets/kenny_cube/Previews/animal-bunny.png';
  static const String villainAsset = 'assets/kenny_cube/Previews/animal-hog.png';

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (imagePath.startsWith('assets/')) {
      img = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => Image.asset(defaultPetAsset, width: width, height: height, fit: fit),
      );
    } else {
      img = Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => Image.asset(defaultPetAsset, width: width, height: height, fit: fit),
      );
    }

    if (isSilhouette) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        child: Opacity(
          opacity: 0.25,
          child: img,
        ),
      );
    }

    return img;
  }
}


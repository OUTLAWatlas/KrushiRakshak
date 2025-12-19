import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RemoteImage extends StatelessWidget {
  const RemoteImage.network(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  })  : assetPath = null,
        isAsset = false;

  const RemoteImage.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  })  : url = null,
        isAsset = true;

  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isAsset;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (ctx, s) => const SizedBox.shrink(),
        errorWidget: (ctx, s, e) => SvgPicture.asset('assets/images/placeholder.svg', width: width, height: height),
      );
    }

    if (assetPath != null) {
      if (assetPath!.endsWith('.svg')) {
        return SvgPicture.asset(assetPath!, width: width, height: height, fit: fit);
      }
      return Image.asset(assetPath!, width: width, height: height, fit: fit);
    }

    return SvgPicture.asset('assets/images/placeholder.svg', width: width, height: height);
  }
}

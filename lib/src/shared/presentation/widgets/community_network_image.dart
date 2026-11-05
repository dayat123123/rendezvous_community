import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_image_scope.dart';
import 'package:rendezvous_community/src/core/network/authorized_image.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/images/community_image_provider.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

CommunityImageProvider communityImageProvider(
  BuildContext context, {
  required String cacheKey,
  required Future<AuthorizedImage> Function() source,
  double? width,
  double? height,
  bool persist = true,
}) {
  final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
  return CommunityImageProvider(
    cacheKey: cacheKey,
    source: source,
    loader: CommunityImageScope.of(context),
    persist: persist && CommunityImagePersistence.of(context),
    targetWidth: communityDecodeDimension(width, dpr),
    targetHeight: communityDecodeDimension(height, dpr),
  );
}

CommunityImageProvider communityUrlImageProvider(BuildContext context, String url, {double? width, double? height}) =>
    communityImageProvider(
      context,
      cacheKey: imageCacheKeyForUrl(url),
      source: () async => AuthorizedImage(url, const {}),
      width: width,
      height: height,
    );

class CommunityNetworkImage extends StatelessWidget {
  const CommunityNetworkImage({
    super.key,
    required this.cacheKey,
    required this.source,
    this.persist = true,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
  });

  CommunityNetworkImage.url(String url, {Key? key, BoxFit fit = BoxFit.cover, Widget? placeholder, Widget? error})
    : this(
        key: key,
        cacheKey: imageCacheKeyForUrl(url),
        source: () async => AuthorizedImage(url, const {}),
        fit: fit,
        placeholder: placeholder,
        error: error,
      );

  final String cacheKey;
  final Future<AuthorizedImage> Function() source;
  final bool persist;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final provider = communityImageProvider(
        context,
        cacheKey: cacheKey,
        source: source,
        width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
        height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
        persist: persist,
      );
      final placeholder = this.placeholder ?? const _ImagePlaceholder(failed: false);
      return Image(
        image: provider,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, synchronous) => frame == null && !synchronous ? placeholder : child,
        errorBuilder: (context, _, _) => error ?? this.placeholder ?? const _ImagePlaceholder(failed: true),
      );
    },
  );
}

Widget communityImagePlaceholder({bool failed = false}) => _ImagePlaceholder(failed: failed);

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.failed});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    final details = CommunityImagePlaceholderDetails(failed: failed);
    return buildSharedPart((b) => b.imagePlaceholder, context, details, _DefaultImagePlaceholder(details: details));
  }
}

class _DefaultImagePlaceholder extends StatelessWidget {
  const _DefaultImagePlaceholder({required this.details});

  final CommunityImagePlaceholderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return SizedBox.expand(
      child: ColoredBox(
        color: style.skeleton,
        child: details.failed ? Center(child: Icon(Icons.broken_image_outlined, color: style.textTertiary)) : null,
      ),
    );
  }
}

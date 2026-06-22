import 'package:flutter/material.dart';

class ProductNetworkImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return _wrap(_placeholder());
    }

    return _wrap(
      Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _loading();
        },
        errorBuilder: (context, error, stackTrace) => _error(),
      ),
    );
  }

  Widget _wrap(Widget child) {
    if (borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
        size: 40,
      ),
    );
  }

  Widget _loading() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 1,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _error() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[500],
            size: 36,
          ),
          const SizedBox(height: 4),
          Text(
            'Image unavailable',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

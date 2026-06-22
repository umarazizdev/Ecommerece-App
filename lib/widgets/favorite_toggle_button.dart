import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/services/favorite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FavoriteToggleButton extends StatelessWidget {
  final String? productId;
  final Map<String, dynamic>? productData;
  final String? favoriteDocId;
  final VoidCallback? onUnfavorited;
  final double iconSize;

  const FavoriteToggleButton({
    super.key,
    this.productId,
    this.productData,
    this.favoriteDocId,
    this.onUnfavorited,
    this.iconSize = 24,
  });

  Future<void> _handleToggle(
    BuildContext context,
    bool isFavorite,
    String? resolvedFavoriteDocId,
  ) async {
    final service = FavoriteService();

    try {
      if (isFavorite) {
        final docId = favoriteDocId ?? resolvedFavoriteDocId;
        if (docId != null) {
          await service.removeFavorite(docId);
          onUnfavorited?.call();
          return;
        }
      }

      if (productId == null || productData == null) return;

      await service.toggleFavorite(
        productId: productId!,
        productData: productData!,
        existingFavoriteDocId: null,
      );
    } catch (error) {
      EasyLoading.showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = FavoriteService();

    if (favoriteDocId != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebasePaths.favoriteDoc(favoriteDocId!).snapshots(),
        builder: (context, snapshot) {
          final isFavorite = snapshot.data?.exists ?? false;
          return _buildButton(
            context,
            isFavorite: isFavorite,
            resolvedFavoriteDocId: favoriteDocId,
          );
        },
      );
    }

    if (productId == null || productData == null) {
      return _buildButton(context, isFavorite: false);
    }

    final productName = productData!['name']?.toString() ?? '';

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: service.watchUserFavorites(),
      builder: (context, snapshot) {
        final favorites = snapshot.data ?? [];
        final isFavorite = service.isProductFavorited(
          favorites,
          productId!,
          productName,
        );
        final resolvedId = service.favoriteDocIdForProduct(
          favorites,
          productId!,
          productName,
        );

        return _buildButton(
          context,
          isFavorite: isFavorite,
          resolvedFavoriteDocId: resolvedId,
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required bool isFavorite,
    String? resolvedFavoriteDocId,
  }) {
    return IconButton(
      onPressed: () => _handleToggle(
        context,
        isFavorite,
        resolvedFavoriteDocId,
      ),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.black,
        size: iconSize,
      ),
    );
  }
}

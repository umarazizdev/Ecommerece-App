import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/utils/auth_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FavoriteService {
  String? get _uid => AuthUtils.currentUid;

  bool _matchesProduct(
    Map<String, dynamic> data,
    String productId,
    String productName,
  ) {
    if (data['uid']?.toString() != _uid) return false;
    if (data['productId']?.toString() == productId) return true;
    return data['productId'] == null &&
        data['name']?.toString() == productName;
  }

  Stream<List<QueryDocumentSnapshot>> watchUserFavorites() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      return const Stream.empty();
    }

    return FirebasePaths.userFavoritesQuery(uid).snapshots().map(
      (snapshot) => snapshot.docs,
    );
  }

  bool isProductFavorited(
    List<QueryDocumentSnapshot> favorites,
    String productId,
    String productName,
  ) {
    return favorites.any((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _matchesProduct(data, productId, productName);
    });
  }

  String? favoriteDocIdForProduct(
    List<QueryDocumentSnapshot> favorites,
    String productId,
    String productName,
  ) {
    for (final doc in favorites) {
      final data = doc.data() as Map<String, dynamic>;
      if (_matchesProduct(data, productId, productName)) {
        return doc.id;
      }
    }
    return null;
  }

  Future<void> addFavorite({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Please login to add favorites');
    }

    await FirebasePaths.favoriteCollection.add({
      'productId': productId,
      'image': productData['image'],
      'name': productData['name'],
      'description': productData['description'],
      'price': productData['price'],
      'uid': uid,
    });
    EasyLoading.showToast('Added to favorites');
  }

  Future<void> removeFavorite(String favoriteDocId) async {
    await FirebasePaths.favoriteDoc(favoriteDocId).delete();
    EasyLoading.showToast('Removed from favorites');
  }

  Future<void> toggleFavorite({
    required String productId,
    required Map<String, dynamic> productData,
    String? existingFavoriteDocId,
  }) async {
    if (existingFavoriteDocId != null) {
      await removeFavorite(existingFavoriteDocId);
      return;
    }

    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Please login to manage favorites');
    }

    final favorites =
        await FirebasePaths.userFavoritesQuery(uid).get();
    final existingId = favoriteDocIdForProduct(
      favorites.docs,
      productId,
      productData['name']?.toString() ?? '',
    );

    if (existingId != null) {
      await removeFavorite(existingId);
    } else {
      await addFavorite(productId: productId, productData: productData);
    }
  }
}

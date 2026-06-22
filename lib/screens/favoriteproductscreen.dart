import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/utils/auth_utils.dart';
import 'package:addproduct/widgets/favorite_toggle_button.dart';
import 'package:addproduct/widgets/firestore_document_screen.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FavoriteProductDetail extends StatelessWidget {
  final String favoriteid;
  const FavoriteProductDetail({super.key, required this.favoriteid});

  Future<void> _addToCart(Map<String, dynamic> data) async {
    try {
      await FirebasePaths.cartitemCollection.add({
        'image': data['image'],
        'name': data['name'],
        'description': data['description'],
        'price': data['price'],
        'uid': AuthUtils.requireUid(),
      });
      EasyLoading.showToast('Added to Cart item');
    } catch (error) {
      EasyLoading.showError('Failed to add to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreDocumentScreen(
      documentRef: FirebasePaths.favoriteDoc(favoriteid),
      title: 'Product Detail',
      builder: (context, data) {
        return Column(
          children: [
            Stack(
              children: [
                ProductNetworkImage(
                  url: data['image']?.toString(),
                  height: 250,
                  width: double.infinity,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: FavoriteToggleButton(
                    favoriteDocId: favoriteid,
                    productId: data['productId']?.toString(),
                    productData: data,
                    onUnfavorited: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['name']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '\$${data['price']}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['description']?.toString() ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      color: Colors.black,
                      onPressed: () => _addToCart(data),
                      child: const Text(
                        'Add To Cart',
                        style: TextStyle(
                          fontSize: 15.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

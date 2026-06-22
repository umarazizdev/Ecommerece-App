import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/widgets/firestore_document_screen.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CartProductDetail extends StatelessWidget {
  final String cartid;
  const CartProductDetail({super.key, required this.cartid});

  Future<void> _removeFromCart(BuildContext context) async {
    try {
      EasyLoading.show();
      await FirebasePaths.cartItemDoc(cartid).delete();
      EasyLoading.showToast('Deleted from shopping cart');
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      EasyLoading.showError('Failed to delete from cart: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreDocumentScreen(
      documentRef: FirebasePaths.cartItemDoc(cartid),
      title: 'Product Detail',
      builder: (context, data) {
        return Column(
          children: [
            ProductNetworkImage(
              url: data['image']?.toString(),
              height: 250,
              width: double.infinity,
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
                      onPressed: () => _removeFromCart(context),
                      child: const Text(
                        'Remove from cart',
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

import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/screens/cartitemdetail.dart';
import 'package:addproduct/screens/jackcash_checkout_screen.dart';
import 'package:addproduct/utils/auth_utils.dart';
import 'package:addproduct/widgets/app_primary_button.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _goToCheckout(
    BuildContext context,
    List<QueryDocumentSnapshot> cartItems,
    double total,
  ) {
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to checkout')),
      );
      return;
    }

    final items = cartItems.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'name': data['name']?.toString() ?? '',
        'description': data['description']?.toString() ?? '',
        'price': data['price']?.toString() ?? '0',
        'image': data['image']?.toString() ?? '',
      };
    }).toList();

    final docIds = cartItems.map((doc) => doc.id).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JackCashCheckoutScreen(
          cartItems: items,
          cartDocIds: docIds,
          total: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthUtils.currentUid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Shopping Cart',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text(
            'Please login to view your cart',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebasePaths.userCartItemsQuery(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 1,
              ),
            );
          }

          final cartItems = snapshot.data?.docs ?? [];
          if (cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final total = cartItems.fold<double>(0, (totalAmount, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price =
                double.tryParse(data['price']?.toString() ?? '0') ?? 0;
            return totalAmount + price;
          });

          return Column(
            children: [
              Expanded(
                child: AlignedGridView.count(
                  padding: const EdgeInsets.all(10),
                  crossAxisCount: 1,
                  mainAxisSpacing: 4,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final data = cartItems[index];
                    final item = data.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 6,
                      shadowColor: Colors.black,
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartProductDetail(
                                    cartid: data.id,
                                  ),
                                ),
                              );
                            },
                            child: ProductNetworkImage(
                              url: item['image']?.toString(),
                              height: 80,
                              width: 90,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']?.toString() ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '\$${item['price']}',
                                    style: TextStyle(
                                      color: Colors.green[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppPrimaryButton(
                        label: 'Checkout',
                        onPressed: () =>
                            _goToCheckout(context, cartItems, total),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

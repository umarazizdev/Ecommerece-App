import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/main.dart';
import 'package:addproduct/utils/auth_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  Future<String> placeOrder({
    required List<Map<String, dynamic>> items,
    required List<String> cartDocIds,
    required String jazzCashNumber,
    String paymentMethod = 'jazzcash',
  }) async {
    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final uid = AuthUtils.requireUid();

    if (cartDocIds.isEmpty) {
      throw Exception('No cart items to checkout');
    }

    final cartDocs = await Future.wait(
      cartDocIds.map((id) => FirebasePaths.cartItemDoc(id).get()),
    );

    final ownedCartIds = <String>[];
    for (final doc in cartDocs) {
      if (!doc.exists) continue;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      if (data['uid']?.toString() == uid) {
        ownedCartIds.add(doc.id);
      }
    }

    if (ownedCartIds.isEmpty) {
      throw Exception('No valid cart items found for your account');
    }

    final total = items.fold<double>(0, (totalAmount, item) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      return totalAmount + price;
    });

    final batch = FirebaseFirestore.instance.batch();

    final orderRef = FirebasePaths.ordersCollection.doc();
    batch.set(orderRef, {
      'userId': uid,
      'userName': box.read('name')?.toString() ?? 'Customer',
      'userEmail': box.read('email')?.toString() ?? '',
      'jazzCashNumber': jazzCashNumber,
      'items': items,
      'itemCount': items.length,
      'totalAmount': total.toStringAsFixed(2),
      'status': 'pending',
      'paymentMethod': paymentMethod,
      'paymentStatus': 'paid',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (final docId in ownedCartIds) {
      batch.delete(FirebasePaths.cartItemDoc(docId));
    }

    await batch.commit();
    return orderRef.id;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await FirebasePaths.ordersCollection.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

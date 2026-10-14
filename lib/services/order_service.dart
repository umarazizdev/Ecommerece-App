import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/main.dart';
import 'package:addproduct/utils/auth_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  // Admin screen ke liye ye list zaruri hai
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
    String? txnRef,
    String paymentMethod = 'jazzcash_sandbox',
  }) async {
    if (items.isEmpty) throw Exception('Cart is empty');
    final uid = AuthUtils.requireUid();

    final total = items.fold<double>(0, (sum, item) {
      return sum + (double.tryParse(item['price']?.toString() ?? '0') ?? 0);
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
      'totalAmount': total,
      'totalAmountFormatted': 'Rs ${total.toStringAsFixed(0)}',
      'currency': 'PKR',
      'status': 'pending',
      'paymentMethod': paymentMethod,
      'paymentStatus': 'paid via JazzCash Sandbox',
      'jazzCashTxnRef': txnRef ?? "T${DateTime.now().millisecondsSinceEpoch}",
      'isSandbox': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (final docId in cartDocIds) {
      batch.delete(FirebasePaths.cartItemDoc(docId));
    }

    await batch.commit();
    return orderRef.id;
  }

  // YEH METHOD MISSING THA - Admin screen ke liye
  Future<void> updateOrderStatus({required String orderId, required String status}) async {
    await FirebasePaths.ordersCollection.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
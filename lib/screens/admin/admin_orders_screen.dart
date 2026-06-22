import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPaymentMethod(String? method) {
    final normalized =
        method?.toLowerCase().replaceAll('_', '').replaceAll(' ', '') ?? '';
    if (normalized == 'jackcash' || normalized == 'jazzcash') {
      return 'JazzCash';
    }
    if (method == null || method.isEmpty) return 'Unknown';
    return method[0].toUpperCase() + method.substring(1);
  }

  Future<void> _updateStatus(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    try {
      EasyLoading.show();
      await OrderService().updateOrderStatus(orderId: orderId, status: status);
      EasyLoading.showSuccess('Order updated');
    } catch (error) {
      EasyLoading.showError('Failed to update order: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showStatusSheet(
    BuildContext context,
    String orderId,
    String currentStatus,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Order Status',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...OrderService.orderStatuses.map((status) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      fontWeight: status == currentStatus
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: status == currentStatus
                      ? const Icon(Icons.check, color: Colors.black)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(context, orderId, status);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Order Management',
          style: TextStyle(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebasePaths.ordersCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),
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

          final orders = snapshot.data?.docs ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status']?.toString() ?? 'pending';
              final items = (data['items'] as List<dynamic>? ?? []);

              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['userName']?.toString() ?? 'Customer',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['userEmail']?.toString() ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(data['createdAt'] as Timestamp?),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${items.length} item(s) · \$${data['totalAmount']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (data['paymentMethod'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Paid via ${_formatPaymentMethod(data['paymentMethod']?.toString())}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (data['jazzCashNumber'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'JazzCash: ${data['jazzCashNumber']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ...items.take(3).map((item) {
                      final product = item as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${product['name']} (\$${product['price']})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }),
                    if (items.length > 3)
                      Text(
                        '+ ${items.length - 3} more item(s)',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        color: Colors.black,
                        onPressed: () =>
                            _showStatusSheet(context, doc.id, status),
                        child: const Text(
                          'Update Status',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

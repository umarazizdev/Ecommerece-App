import 'package:addproduct/services/order_service.dart';
import 'package:addproduct/widgets/app_primary_button.dart';
import 'package:addproduct/widgets/app_text_field.dart';
import 'package:addproduct/widgets/dismiss_keyboard.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class JackCashCheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final List<String> cartDocIds;
  final double total;

  const JackCashCheckoutScreen({
    super.key,
    required this.cartItems,
    required this.cartDocIds,
    required this.total,
  });

  @override
  State<JackCashCheckoutScreen> createState() => _JackCashCheckoutScreenState();
}

class _JackCashCheckoutScreenState extends State<JackCashCheckoutScreen> {
  final _phoneController = TextEditingController();
  final _orderService = OrderService();
  bool _isProcessing = false;
  bool _orderPlaced = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  bool _isValidJazzCashNumber(String value) {
    final digits = _normalizePhone(value);
    return digits.length == 11;
  }

  Future<void> _placeOrder() async {
    if (_isProcessing || _orderPlaced) return;

    final jazzCashNumber = _normalizePhone(_phoneController.text);
    if (!_isValidJazzCashNumber(jazzCashNumber)) {
      EasyLoading.showError('Enter a valid 11-digit JazzCash number');
      return;
    }

    setState(() => _isProcessing = true);
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      EasyLoading.show(status: 'Placing order...');

      await _orderService.placeOrder(
        items: widget.cartItems,
        cartDocIds: widget.cartDocIds,
        jazzCashNumber: jazzCashNumber,
        paymentMethod: 'jazzcash',
      );

      _orderPlaced = true;
      EasyLoading.showSuccess('Order placed successfully!');
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      EasyLoading.showError(
        message.contains('PERMISSION_DENIED')
            ? 'Permission denied. Please login again or contact support.'
            : message,
      );
      if (mounted) setState(() => _isProcessing = false);
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _onPhoneChanged(String value) {
    setState(() {});
  }

  bool get _canPay =>
      !_isProcessing && !_orderPlaced && _isValidJazzCashNumber(_phoneController.text);

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'JazzCash Checkout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'JazzCash',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your JazzCash number and confirm payment',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...widget.cartItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ProductNetworkImage(
                        url: item['image']?.toString(),
                        height: 50,
                        width: 50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${item['price']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${widget.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'JazzCash Number',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your 11-digit JazzCash mobile number.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _phoneController,
                hintText: '03XXXXXXXXX',
                keyboardType: TextInputType.phone,
                height: 50,
                onChanged: _onPhoneChanged,
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: _canPay ? 1 : 0.5,
                child: AppPrimaryButton(
                  label: _isProcessing ? 'Processing...' : 'Pay with JazzCash',
                  onPressed: _canPay ? _placeOrder : () {},
                ),
              ),
              if (_isProcessing) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

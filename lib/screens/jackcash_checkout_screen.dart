import 'package:addproduct/screens/jazzcash_webview.dart';
import 'package:flutter/material.dart';

class JackCashCheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final List<String> cartDocIds;
  final double total;
  
  const JackCashCheckoutScreen({
    super.key, 
    required this.cartItems, 
    required this.cartDocIds, 
    required this.total
  });

  @override
  State<JackCashCheckoutScreen> createState() => _JackCashCheckoutScreenState();
}

class _JackCashCheckoutScreenState extends State<JackCashCheckoutScreen> {
  final _numberController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _pay() {
    if (_numberController.text.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid JazzCash number"))
      );
      return;
    }

    // WebView Sandbox pe le jao
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JazzCashWebView(
          amount: widget.total.toStringAsFixed(0),
          cartItems: widget.cartItems,
          cartDocIds: widget.cartDocIds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JazzCash Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 40, color: Colors.red),
                  const SizedBox(height: 8),
                  Text("Pay: Rs ${widget.total.toStringAsFixed(0)}", 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("JazzCash Sandbox Mode", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "JazzCash Number",
                hintText: "03001234567",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _loading ? null : _pay,
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text("Pay Rs ${widget.total.toStringAsFixed(0)} with JazzCash"),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Note: This will open JazzCash Sandbox page for testing.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

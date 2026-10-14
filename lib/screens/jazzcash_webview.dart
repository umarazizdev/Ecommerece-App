import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:addproduct/services/jazzcash_sandbox_service.dart';
import 'package:addproduct/services/order_service.dart';

class JazzCashWebView extends StatefulWidget {
  final String amount;
  final List<Map<String, dynamic>> cartItems;
  final List<String> cartDocIds;
  const JazzCashWebView({super.key, required this.amount, required this.cartItems, required this.cartDocIds});

  @override
  State<JazzCashWebView> createState() => _JazzCashWebViewState();
}

class _JazzCashWebViewState extends State<JazzCashWebView> {
  late final WebViewController controller;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    String html = JazzCashSandboxService.generateHtml(amount: widget.amount);

    controller = WebViewController()
     ..setJavaScriptMode(JavaScriptMode.unrestricted)
     ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          // Agar Return URL pe aa jaye to Order Save kar do
          if (url.contains("DoTransaction") &&!isPaid) {
            isPaid = true;
            await OrderService().placeOrder(
              items: widget.cartItems,
              cartDocIds: widget.cartDocIds,
              jazzCashNumber: "03001234567",
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paid Rs ${widget.amount} - Sandbox Success")));
              Navigator.popUntil(context, (r) => r.isFirst);
            }
          }
        },
      ))
     ..loadRequest(Uri.dataFromString(html, mimeType: 'text/html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JazzCash Sandbox")),
      body: WebViewWidget(controller: controller),
    );
  }
}
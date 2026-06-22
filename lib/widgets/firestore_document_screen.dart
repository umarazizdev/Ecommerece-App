import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef DocumentDataBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> data,
);

class FirestoreDocumentScreen extends StatefulWidget {
  final DocumentReference documentRef;
  final String title;
  final DocumentDataBuilder builder;
  final Widget? floatingActionButton;

  const FirestoreDocumentScreen({
    super.key,
    required this.documentRef,
    required this.title,
    required this.builder,
    this.floatingActionButton,
  });

  @override
  State<FirestoreDocumentScreen> createState() =>
      _FirestoreDocumentScreenState();
}

class _FirestoreDocumentScreenState extends State<FirestoreDocumentScreen> {
  late final Stream<DocumentSnapshot> _documentStream;

  @override
  void initState() {
    super.initState();
    _documentStream = widget.documentRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _documentStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorBody(error: snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 1,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Item not found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return widget.builder(context, data);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String error;

  const _ErrorBody({required this.error});

  @override
  Widget build(BuildContext context) {
    final isPermission = error.contains('PERMISSION_DENIED');
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              isPermission
                  ? 'Permission denied. Please deploy Firestore rules for the ecommerce collections.'
                  : 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

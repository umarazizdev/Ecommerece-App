import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CartProductDetail extends StatefulWidget {
  final String cartid;
  const CartProductDetail({super.key, required this.cartid});

  @override
  State<CartProductDetail> createState() => _CartProductDetailState();
}

class _CartProductDetailState extends State<CartProductDetail> {
  CollectionReference productdet =
      FirebaseFirestore.instance.collection('cartitem');

  CollectionReference users = FirebaseFirestore.instance.collection('cartitem');

  Future<void> deleteUser(String id) {
    return users.doc(id).delete().then((value) {
      EasyLoading.showToast("Deleted From Shopping cart");
    }).catchError((error) {
      EasyLoading.showError("Failed to delete From Shopping cart: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Product Detail",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: productdet.doc(widget.cartid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        data['image'],
                      ),
                    ),
                    // borderRadius: BorderRadius.circular(12),
                  ),
                  height: 250,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['name'],
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "\$${data['price']}",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[200]),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        data['description'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SizedBox(
          height: 45,
          width: double.infinity,
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
            onPressed: () {
              deleteUser(widget.cartid);
              EasyLoading.show();
            },
            child: const Text(
              "Remove from cart",
              style: TextStyle(
                  fontSize: 15.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

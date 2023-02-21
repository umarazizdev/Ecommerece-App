import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ProductDetail extends StatefulWidget {
  final String documentId;
  const ProductDetail({super.key, required this.documentId});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  CollectionReference productdet =
      FirebaseFirestore.instance.collection('products');

  CollectionReference users = FirebaseFirestore.instance.collection('favorite');
  CollectionReference cartitem =
      FirebaseFirestore.instance.collection('cartitem');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: productdet.doc(widget.documentId).get(),
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
            body: Column(
              children: [
                Stack(
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
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          users.add({
                            'image': data['image'],
                            'name': data['name'],
                            'description': data['description'],
                            'price': data['price']
                          }).then((value) {
                            EasyLoading.showToast("Added to favorite");
                          }).catchError((error) {
                            EasyLoading.showError(
                                "Failed to add favorite: $error");
                          });
                        },
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
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
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
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
                    cartitem.add({
                      'image': data['image'],
                      'name': data['name'],
                      'description': data['description'],
                      'price': data['price']
                    }).then((value) {
                      EasyLoading.showToast("Added to Cart item");
                    }).catchError((error) {
                      EasyLoading.showError("Failed to add to cart: $error");
                    });
                  },
                  child: const Text(
                    "Add To Cart",
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

        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
          ),
        );
      },
    );
  }
}

// ??????????????????????????????????
// 


// ????????????????????????????????????????????
      /*


*/
// ?????????????????????????????????????????????????????????????????????????????????????/??????????????????????????????????????????????????????????????????????????????????????????????????????????/
      /*

      */

















// ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 // const SizedBox(
                      //   height: 87,
                      // ),
                      // SizedBox(
                      //   height: 45,
                      //   width: double.infinity,
                      //   child: MaterialButton(
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(35)),
                      //     color: Colors.black,
                      //     child: const Text(
                      //       "Add to cart",
                      //       style: TextStyle(
                      //           fontSize: 15.5,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500),
                      //     ),
                      //     onPressed: () {

                      //     },
                      //   ),
                      // )
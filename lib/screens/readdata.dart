import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/widgets/favorite_toggle_button.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadData extends StatefulWidget {
  const ReadData({super.key});

  @override
  State<ReadData> createState() => _ReadDataState();
}

class _ReadDataState extends State<ReadData> {
  final Stream<QuerySnapshot> _usersStream =
      FirebasePaths.productsCollection.snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return Expanded(
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ProductNetworkImage(
                                url: data['image']?.toString(),
                                height: 250,
                                width: double.infinity,
                              ),
                              Positioned(
                                right: 0,
                                child: FavoriteToggleButton(
                                  productId: document.id,
                                  productData: data,
                                ),
                              ),
                            ],
                          ),
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
                          const SizedBox(
                            height: 150,
                          ),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35)),
                              color: Colors.black,
                              child: const Text(
                                "Add to cart",
                                style: TextStyle(
                                    fontSize: 15.5,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

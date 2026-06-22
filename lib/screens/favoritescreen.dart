import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/screens/favoriteproductscreen.dart';
import 'package:addproduct/utils/auth_utils.dart';
import 'package:addproduct/widgets/favorite_toggle_button.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Favoritescreen extends StatefulWidget {
  const Favoritescreen({super.key});

  @override
  State<Favoritescreen> createState() => _FavoritescreenState();
}

class _FavoritescreenState extends State<Favoritescreen> {
  @override
  Widget build(BuildContext context) {
    final uid = AuthUtils.currentUid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: uid == null
            ? const Center(
                child: Text(
                  'Please login to view favorites',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebasePaths.userFavoritesQuery(uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                            ),
                          );
                        }

                        final favorites = snapshot.data?.docs ?? [];
                        if (favorites.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'No favorites yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return AlignedGridView.count(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final data = favorites[index];
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FavoriteProductDetail(
                                        favoriteid: data.id,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        ProductNetworkImage(
                                          url: data['image']?.toString(),
                                          height: 160,
                                          width: double.infinity,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: FavoriteToggleButton(
                                            favoriteDocId: data.id,
                                            productId:
                                                data['productId']?.toString(),
                                            productData: data.data()
                                                as Map<String, dynamic>,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['name'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['price'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

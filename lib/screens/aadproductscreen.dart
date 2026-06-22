import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/firebase_paths.dart';
import '../main.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  CollectionReference users = FirebasePaths.productsCollection;
  XFile? singleImage;
  chooseImage() async {
    return await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  String getImageName(XFile image) {
    return image.path.split("/").last;
  }

  Future<void> uploadImage(XFile image) async {
    try {
      EasyLoading.show(status: 'Uploading product...');
      final db = FirebasePaths.productImageRef(getImageName(image));
      await db.putFile(File(image.path));
      final imageUrl = await db.getDownloadURL();

      await users.add({
        'image': imageUrl,
        'name': name.text.trim(),
        'description': description.text.trim(),
        'price': price.text.trim(),
        'star1': 0,
        'star2': 0,
        'star3': 0,
        'star4': 0,
        'star5': 0,
        'publish': false,
        'uid': box.read('uid'),
      });

      name.clear();
      description.clear();
      price.clear();
      if (mounted) {
        setState(() => singleImage = null);
      }
      EasyLoading.showSuccess('Successfully Added');
    } catch (error) {
      EasyLoading.showError('Failed to add product: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Products",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    singleImage = await chooseImage();
                    if (singleImage != null && singleImage!.path.isNotEmpty) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: singleImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(singleImage!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.image,
                                ),
                                Text(
                                  "Add Image",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: name,
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Product Name";
                      }
                      return null;
                    }),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      hintText: "Enter Product name",
                      hintStyle: const TextStyle(fontSize: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: description,
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Product description";
                      }
                      return null;
                    }),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      hintText: "Enter Product Description",
                      hintStyle: const TextStyle(fontSize: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: price,
                    validator: ((value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Product Price";
                      }
                      return null;
                    }),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      hintStyle: const TextStyle(fontSize: 15),
                      hintText: "Enter Product Price",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    color: Colors.black,
                    child: const Text(
                      "Add Product",
                      style: TextStyle(
                          fontSize: 15.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (singleImage != null &&
                            singleImage!.path.isNotEmpty) {
                          await uploadImage(singleImage!);
                        } else {
                          EasyLoading.showToast('Please Select Image');
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

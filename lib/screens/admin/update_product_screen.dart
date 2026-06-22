import 'dart:io';

import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/widgets/app_primary_button.dart';
import 'package:addproduct/widgets/app_text_field.dart';
import 'package:addproduct/widgets/product_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProductScreen extends StatefulWidget {
  final String productId;

  const UpdateProductScreen({super.key, required this.productId});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _currentImageUrl;
  XFile? _newImage;
  bool _isPublished = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final doc =
          await FirebasePaths.productsCollection.doc(widget.productId).get();
      if (!doc.exists) {
        EasyLoading.showError('Product not found');
        if (mounted) Navigator.pop(context);
        return;
      }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      _nameController.text = data['name']?.toString() ?? '';
      _descriptionController.text = data['description']?.toString() ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _currentImageUrl = data['image']?.toString();
      _isPublished = data['publish'] == true;
    } catch (error) {
      EasyLoading.showError('Failed to load product: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _newImage = image);
    }
  }

  String _imageFileName(XFile image) => image.path.split('/').last;

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      EasyLoading.show(status: 'Updating product...');

      String imageUrl = _currentImageUrl ?? '';
      if (_newImage != null) {
        final ref = FirebasePaths.productImageRef(_imageFileName(_newImage!));
        await ref.putFile(File(_newImage!.path));
        imageUrl = await ref.getDownloadURL();
      }

      await FirebasePaths.productsCollection.doc(widget.productId).update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': _priceController.text.trim(),
        'image': imageUrl,
        'publish': _isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      EasyLoading.showSuccess('Product updated');
      if (mounted) Navigator.pop(context);
    } catch (error) {
      EasyLoading.showError('Failed to update product: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
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
          'Update Product',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 1,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _newImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_newImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : ProductNetworkImage(
                                  url: _currentImageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Tap image to change',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        controller: _nameController,
                        hintText: 'Product Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        controller: _descriptionController,
                        hintText: 'Product Description',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        controller: _priceController,
                        hintText: 'Product Price',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Publish Product',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Switch(
                              value: _isPublished,
                              activeThumbColor: Colors.white,
                              activeTrackColor: Colors.black,
                              onChanged: (value) {
                                setState(() => _isPublished = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppPrimaryButton(
                        label: 'Save Changes',
                        onPressed: _updateProduct,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

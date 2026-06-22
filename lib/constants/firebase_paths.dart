import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebasePaths {
  static const String ecommerce = 'ecommerce';
  static const String rootDoc = 'app';
  static const String products = 'products';
  static const String favorite = 'favorite';
  static const String cartitem = 'cartitem';
  static const String users = 'users';
  static const String orders = 'orders';
  static const String images = 'image';

  static DocumentReference get _root =>
      FirebaseFirestore.instance.collection(ecommerce).doc(rootDoc);

  static CollectionReference get productsCollection =>
      _root.collection(products);

  static DocumentReference productDoc(String productId) =>
      productsCollection.doc(productId);

  static CollectionReference get favoriteCollection =>
      _root.collection(favorite);

  static DocumentReference favoriteDoc(String favoriteId) =>
      favoriteCollection.doc(favoriteId);

  static CollectionReference get cartitemCollection =>
      _root.collection(cartitem);

  static DocumentReference cartItemDoc(String cartId) =>
      cartitemCollection.doc(cartId);

  static Query userCartItemsQuery(String uid) =>
      cartitemCollection.where('uid', isEqualTo: uid);

  static Query userFavoritesQuery(String uid) =>
      favoriteCollection.where('uid', isEqualTo: uid);

  static CollectionReference get usersCollection => _root.collection(users);

  static CollectionReference get ordersCollection => _root.collection(orders);

  static DocumentReference userDoc(String uid) => usersCollection.doc(uid);

  static Reference productImageRef(String fileName) =>
      FirebaseStorage.instance.ref('$ecommerce/$images/$fileName');
}

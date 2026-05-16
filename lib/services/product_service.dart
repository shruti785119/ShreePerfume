import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> addProduct(Map<String, dynamic> data) async {
    await _db.collection("product").add(data);
  }

  static Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.collection("product").doc(id).update(data);
  }

  static Future<void> deleteProduct(String id) async {
    await _db.collection("product").doc(id).delete();
  }

  static Stream<QuerySnapshot> getProducts() {
    return _db.collection("product").snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getCategories() {
    return _db.collection("category").snapshots();
  }

  static Future<void> addCategory(Map<String, dynamic> data) async {
    await _db.collection("category").add(data);
  }

  static Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _db.collection("category").doc(id).update(data);
  }

  static Future<void> deleteCategory(String id) async {
    await _db.collection("category").doc(id).delete();
  }
}

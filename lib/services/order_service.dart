import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;

  // Create new order in Firestore
  static Future<String> createOrder({
    required String customerName,
    required String shippingAddress,
    required String city,
    required String paymentLabel,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerId,
    required String customerEmail,
  }) async {
    final orderId = _generateOrderId();
    
    await _db.collection('orders').doc(orderId).set({
      'id': orderId,
      'customerId': customerId ?? '',
      'customerEmail': customerEmail.trim().toLowerCase(),
      'placedAt': DateTime.now(),
      'status': 'Pending', // Pending, Processing, Shipped, Delivered
      'items': items,
      'totalAmount': totalAmount,
      'shippingName': customerName,
      'shippingAddress': shippingAddress,
      'city': city,
      'paymentLabel': paymentLabel,
    });
    
    return orderId;
  }

  // Get all orders (admin only)
  static Stream<QuerySnapshot> getAllOrders() {
    return _db.collection('orders').orderBy('placedAt', descending: true).snapshots();
  }

  // Update order status (admin only)
  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  // Generate unique order ID
  static String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'ORD-$timestamp-$random';
  }
}

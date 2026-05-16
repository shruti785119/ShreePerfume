import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
//for order management
import '../services/order_service.dart';
import '../models/order_model.dart';
class AppState extends ChangeNotifier {
  AppState._() {
    _listenToProducts();
    _listenToCategories();
    // for order
    _listenToOrders();
  }

  static final AppState instance = AppState._();

  final List<Product> _products = [];
  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);

  void _listenToProducts() {
    ProductService.getProducts().listen((snapshot) {
      print('📦 Products loaded: ${snapshot.docs.length} items');
      _products
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String imagePath = (data['p_image'] ?? '').toString().trim();
          if (imagePath == 'assets/' || imagePath.isEmpty) {
            imagePath = 'assets/about.jpg';
          } else if (!imagePath.startsWith('assets/') && !imagePath.contains('://')) {
            imagePath = 'assets/$imagePath';
          }

//           String imagePath = (data['p_image'] ?? '').toString().trim();
// if (imagePath.isNotEmpty) {
//   imagePath = 'assets/' + imagePath;   // prepend assets/
// } else {
//   imagePath = 'assets/about.jpg';
// }


          return Product(
            id: doc.id,
            title: data['p_title'] ?? 'Unknown Product',
            brand: data['p_brand'] ?? 'SHREE',
            price: (data['p_price'] ?? 0).toDouble(),
            image: imagePath,
            description: data['p_description'] ?? 'Premium fragrance',
            category: data['p_category'] ?? 'General',
            scentFamily: data['p_scentFamily'] ?? 'Signature',
            overlay: const Color(0x221FD58B),
          );
        }));
      notifyListeners();
    }, onError: (e) {
      print('❌ Error loading products: $e');
    });
  }


//for category management
void _listenToCategories() {
  CategoryService.getCategories().listen((snapshot) {
    _categories
      ..clear()
      ..addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppCategory(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
        );
      }));
    notifyListeners();
  }, onError: (e) {
    print('❌ Error loading categories: $e');
  });
}
//for order management
void _listenToOrders() {
  OrderService.getAllOrders().listen((snapshot) {
    _orders
      ..clear()
      ..addAll(snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>? ?? [])
            .map((itemData) => OrderItem(
                  productId: itemData['productId'] ?? '',
                  title: itemData['title'] ?? '',
                  image: itemData['image'] ?? '',
                  quantity: itemData['quantity'] ?? 0,
                  unitPrice: (itemData['unitPrice'] ?? 0).toDouble(),
                ))
            .toList();

        return OrderRecord(
          id: data['id'] ?? '',
          customerId: data['customerId'] as String? ?? '',
          customerEmail:
              (data['customerEmail'] as String? ?? '').trim().toLowerCase(),
          placedAt: (data['placedAt'] as Timestamp).toDate(),
          status: data['status'] ?? 'Pending',
          items: items,
          totalAmount: (data['totalAmount'] ?? 0).toDouble(),
          shippingName: data['shippingName'] ?? '',
          shippingAddress: data['shippingAddress'] ?? '',
          city: data['city'] ?? '',
          paymentLabel: data['paymentLabel'] ?? '',
        );
      }));
    notifyListeners();
  }, onError: (e) {
    print('❌ Error loading orders: $e');
  });
}

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await OrderService.updateOrderStatus(orderId, newStatus);
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required String category,
    String image = '',
  }) async {
    await ProductService.addProduct({
      'p_title': name,
      'p_price': price,
      'p_category': category,
      'p_brand': 'SHREE PERFUME',
      'p_description': '$name is a fragrance from $category collection.',
      'p_image': image.isNotEmpty ? image : 'assets/about.jpg',
      'p_scentFamily': 'Signature',
      'p_overlay': 0,
    });
  }
//--------------------------------------


  Future<void> updateProduct(Product product,
      {required String name, required double price, required String category, String image = ''}) async {
    final updateData = {
      'p_title': name,
      'p_price': price,
      'p_category': category,
      'p_description': '$name is a fragrance from $category collection.',
    };
    if (image.isNotEmpty) {
      updateData['p_image'] = image;
    }
    await ProductService.updateProduct(product.id, updateData);
  }

  Future<void> deleteProduct(Product product) async {
    await ProductService.deleteProduct(product.id);
  }

  static const String _fallbackCategory = 'Uncategorized';

  final Set<String> _wishlistIds = <String>{};
  final Map<String, int> _cartQuantities = <String, int>{};
  final List<OrderRecord> _orders = <OrderRecord>[];
  final List<AppUser> _users = <AppUser>[];
  final List<AppCategory> _categories = <AppCategory>[];

  UnmodifiableListView<AppUser> get users => UnmodifiableListView(_users);
  UnmodifiableListView<AppCategory> get categories =>
      UnmodifiableListView(_categories);
  UnmodifiableListView<OrderRecord> get orders => UnmodifiableListView(_orders);

  List<Product> get wishlistProducts =>
      _products.where((product) => _wishlistIds.contains(product.id)).toList();

  List<CartEntry> get cartEntries => _products
      .where((product) => _cartQuantities.containsKey(product.id))
      .map(
        (product) => CartEntry(
          product: product,
          quantity: _cartQuantities[product.id] ?? 1,
        ),
      )
      .toList();

  bool isInWishlist(Product product) => _wishlistIds.contains(product.id);
  bool isInCart(Product product) => _cartQuantities.containsKey(product.id);
  int quantityFor(Product product) => _cartQuantities[product.id] ?? 0;

  int get cartItemCount =>
      _cartQuantities.values.fold(0, (total, quantity) => total + quantity);

  double get subtotal =>
      cartEntries.fold(0, (total, entry) => total + entry.totalPrice);

  bool emailExists(String email, {String? exceptId}) {
    final normalizedEmail = email.trim().toLowerCase();
    return _users.any(
      (user) =>
          user.email.toLowerCase() == normalizedEmail && user.id != exceptId,
    );
  }

  bool categoryExists(String name, {String? exceptId}) {
    final normalizedName = name.trim().toLowerCase();
    return _categories.any(
      (category) =>
          category.name.toLowerCase() == normalizedName &&
          category.id != exceptId,
    );
  }

  int productCountForCategory(String categoryName) {
    return _products
        .where((product) => product.category == categoryName)
        .length;
  }

  void toggleWishlist(Product product) {
    if (_wishlistIds.contains(product.id)) {
      _wishlistIds.remove(product.id);
    } else {
      _wishlistIds.add(product.id);
    }
    notifyListeners();
  }

  void addToWishlist(Product product) {
    if (_wishlistIds.add(product.id)) {
      notifyListeners();
    }
  }

  void removeFromWishlist(Product product) {
    if (_wishlistIds.remove(product.id)) {
      notifyListeners();
    }
  }

  void addToCart(Product product) {
    _cartQuantities.update(product.id, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final current = _cartQuantities[product.id];
    if (current == null) return;

    if (current <= 1) {
      _cartQuantities.remove(product.id);
    } else {
      _cartQuantities[product.id] = current - 1;
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (_cartQuantities.remove(product.id) != null) {
      notifyListeners();
    }
  }

  void clearCart() {
    if (_cartQuantities.isEmpty) return;
    _cartQuantities.clear();
    notifyListeners();
  }

  Future<void> placeOrder({
    required String customerName,
    required String shippingAddress,
    required String city,
    required String paymentLabel,
    String? customerId,
    required String customerEmail,
  }) async {
    final entries = cartEntries;
    if (entries.isEmpty) return;

    final items = entries
        .map(
          (entry) => OrderItem(
            productId: entry.product.id,
            title: entry.product.title,
            image: entry.product.image,
            quantity: entry.quantity,
            unitPrice: entry.product.price,
          ),
        )
        .toList(growable: false);

    final totalAmount = items.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );

    // Convert items to Firebase format
    final itemsData = items
        .map((item) => {
              'productId': item.productId,
              'title': item.title,
              'image': item.image,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
            })
        .toList();

    // for order management
    // Save to Firebase
    await OrderService.createOrder(
      customerName: customerName.trim(),
      shippingAddress: shippingAddress.trim(),
      city: city.trim(),
      paymentLabel: paymentLabel,
      items: itemsData,
      totalAmount: totalAmount,
      customerId: customerId,
      customerEmail: customerEmail.trim().toLowerCase(),
    );

    _cartQuantities.clear();
    notifyListeners();
  }
//---------------------------------

  void moveWishlistToCart(Product product) {
    _wishlistIds.remove(product.id);
    _cartQuantities.update(product.id, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void addUser({
    required String name,
    required String email,
    required String role,
  }) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim().toLowerCase();

    final user = AppUser(
      id: _createUserId(trimmedName, trimmedEmail),
      name: trimmedName,
      email: trimmedEmail,
      role: role,
      memberSince: DateTime.now(),
    );

    _users.insert(0, user);
    notifyListeners();
  }

  void updateUser(
    AppUser user, {
    required String name,
    required String email,
    required String role,
  }) {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index == -1) return;

    _users[index] = user.copyWith(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: role,
    );
    notifyListeners();
  }

  void deleteUser(AppUser user) {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index == -1) return;

    _users.removeAt(index);
    notifyListeners();
  }

Future<void> addCategory({required String name, required String description}) async {
  final trimmedName = name.trim();
  final trimmedDescription = description.trim();

  await CategoryService.addCategory({
    'name': trimmedName,
    'description': trimmedDescription,
  });
}

Future<void> updateCategory(
  AppCategory category, {
  required String name,
  required String description,
}) async {
  final trimmedName = name.trim();
  final trimmedDescription = description.trim();

  await CategoryService.updateCategory(category.id, {
    'name': trimmedName,
    'description': trimmedDescription,
  });
}


Future<void> deleteCategory(AppCategory category) async {
  await CategoryService.deleteCategory(category.id);
}

  String fallbackCategoryFor(String categoryName) {
    return _fallbackForDeletedCategory(categoryName);
  }

  String _buildDescription(String name, String category) {
    return '$name is a signature fragrance from the $category collection.';
  }
Future<void> reassignProducts(String fromCategory, String toCategory) async {
  for (var product in _products) {
    if (product.category == fromCategory) {
      await ProductService.updateProduct(product.id, {
        'p_category': toCategory,
        'p_description': _buildDescription(product.title, toCategory),
      });
    }
  }
}



 void ensureCategoryExists(String name) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty || categoryExists(trimmedName)) return;

  _categories.insert(
    0,
    AppCategory(
      id: _createCategoryId(trimmedName),
      name: trimmedName,
      description: 'Products grouped under the $trimmedName collection.',
    ),
  );
}

  String _fallbackForDeletedCategory(String categoryName) {
    if (categoryName == _fallbackCategory) {
      return 'General';
    }
    return _fallbackCategory;
  }

  String _createUserId(String name, String email) {
    final emailSlug = _slugify(email.split('@').first);
    final baseSlug = emailSlug.isEmpty ? _slugify(name) : emailSlug;
    var candidate = baseSlug.isEmpty ? 'user' : baseSlug;
    var suffix = 1;

    while (_users.any((user) => user.id == candidate)) {
      suffix += 1;
      candidate = '$baseSlug-$suffix';
    }

    return candidate;
  }

  String _createCategoryId(String name) {
    final slug = _slugify(name);
    var candidate = slug;
    var suffix = 1;

    while (_categories.any((category) => category.id == candidate)) {
      suffix += 1;
      candidate = '$slug-$suffix';
    }

    return candidate;
  }

  String _slugify(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'item' : normalized;
  }
}

class CartEntry {
  CartEntry({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get totalPrice => product.price * quantity;
}

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final String? selectedSize;
  final String? selectedColor;
  int quantity;

  CartItem({
    required this.product,
    this.selectedSize,
    this.selectedColor,
    this.quantity = 1,
  });

  double get totalPrice => product.finalPrice * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  void addItem(
    Product product, {
    String? selectedSize,
    String? selectedColor,
    int quantity = 1,
  }) {
    // إنشاء مفتاح فريد بناءً على المنتج والحجم واللون
    final key = '${product.id}_${selectedSize ?? 'default'}_${selectedColor ?? 'default'}';

    if (_items.containsKey(key)) {
      // إذا كان المنتج موجوداً بالفعل، زيادة الكمية
      _items[key]!.quantity += quantity;
    } else {
      // إضافة منتج جديد
      _items[key] = CartItem(
        product: product,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void updateQuantity(String key, int quantity) {
    if (_items.containsKey(key)) {
      if (quantity > 0) {
        _items[key]!.quantity = quantity;
      } else {
        _items.remove(key);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.keys.any((key) => key.startsWith(productId));
  }
}

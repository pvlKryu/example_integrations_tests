import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Состояние корзины. Без внешней персистентности — удобно для изоляции тестов.
class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalKopecks =>
      _items.fold(0, (sum, item) => sum + item.lineTotalKopecks);

  bool get isEmpty => _items.isEmpty;

  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void increase(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = current.copyWith(quantity: current.quantity + 1);
    notifyListeners();
  }

  void decrease(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    final current = _items[index];
    if (current.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

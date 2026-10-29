import 'package:flutter/foundation.dart';

/// Стабильные ValueKey для интеграционных тестов.
abstract final class AppKeys {
  static const catalogScreen = ValueKey('catalog-screen');
  static const catalogLoading = ValueKey('catalog-loading');
  static const catalogError = ValueKey('catalog-error');
  static const catalogEmpty = ValueKey('catalog-empty');
  static const retryButton = ValueKey('retry-button');
  static const cartButton = ValueKey('cart-button');
  static const cartBadge = ValueKey('cart-badge');

  static const productDetailScreen = ValueKey('product-detail-screen');
  static const productDetailName = ValueKey('product-detail-name');
  static const productDetailPrice = ValueKey('product-detail-price');
  static const addConfirmation = ValueKey('add-confirmation');

  static const cartScreen = ValueKey('cart-screen');
  static const cartEmpty = ValueKey('cart-empty');
  static const cartTotal = ValueKey('cart-total');
  static const checkoutButton = ValueKey('checkout-button');
  static const checkoutError = ValueKey('checkout-error');

  static const orderSuccess = ValueKey('order-success');
  static const orderNumber = ValueKey('order-number');
  static const orderTotal = ValueKey('order-total');
  static const backToCatalog = ValueKey('back-to-catalog');

  static ValueKey productCard(String id) => ValueKey('product-card-$id');
  static ValueKey addToCart(String id) => ValueKey('add-to-cart-$id');
  static ValueKey cartItem(String id) => ValueKey('cart-item-$id');
  static ValueKey increase(String id) => ValueKey('increase-$id');
  static ValueKey decrease(String id) => ValueKey('decrease-$id');
  static ValueKey remove(String id) => ValueKey('remove-$id');
}

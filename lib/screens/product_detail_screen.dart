import 'package:flutter/material.dart';

import '../keys.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../utils/money.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cartState,
  });

  final Product product;
  final CartState cartState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppKeys.productDetailScreen,
      appBar: AppBar(title: const Text('Карточка товара')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              key: AppKeys.productDetailName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              formatPrice(product.priceKopecks),
              key: AppKeys.productDetailPrice,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: AppKeys.addToCart(product.id),
                onPressed: () {
                  cartState.addProduct(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      key: AppKeys.addConfirmation,
                      content: Text('${product.name} добавлен в корзину'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Добавить в корзину'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

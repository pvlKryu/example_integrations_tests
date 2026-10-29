import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../keys.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../utils/money.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

enum _CatalogStatus { loading, ready, empty, error }

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.apiClient,
    required this.cartState,
  });

  final ApiClient apiClient;
  final CartState cartState;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  _CatalogStatus _status = _CatalogStatus.loading;
  List<Product> _products = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _status = _CatalogStatus.loading;
      _errorMessage = null;
    });
    try {
      final products = await widget.apiClient.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _status =
            products.isEmpty ? _CatalogStatus.empty : _CatalogStatus.ready;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _CatalogStatus.error;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _CatalogStatus.error;
        _errorMessage = 'Не удалось загрузить каталог';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppKeys.catalogScreen,
      appBar: AppBar(
        title: const Text('Учебный каталог'),
        actions: [
          // Слушаем только корзину — без пересоздания MaterialApp.
          ListenableBuilder(
            listenable: widget.cartState,
            builder: (context, _) {
              return IconButton(
                key: AppKeys.cartButton,
                tooltip: 'Корзина',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CartScreen(
                        apiClient: widget.apiClient,
                        cartState: widget.cartState,
                      ),
                    ),
                  );
                },
                // Без Material Badge/Hero — иначе pushReplacement после
                // оформления заказа ломает анимацию в интеграционных тестах.
                icon: _CartIcon(quantity: widget.cartState.totalQuantity),
              );
            },
          ),
        ],
      ),
      body: switch (_status) {
        _CatalogStatus.loading => const Center(
            child: CircularProgressIndicator(key: AppKeys.catalogLoading),
          ),
        _CatalogStatus.error => _ErrorView(
            message: _errorMessage ?? 'Ошибка',
            onRetry: _load,
          ),
        _CatalogStatus.empty => const Center(
            child: Text(
              'Каталог пуст',
              key: AppKeys.catalogEmpty,
              style: TextStyle(fontSize: 18),
            ),
          ),
        _CatalogStatus.ready => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = _products[index];
              return Card(
                key: AppKeys.productCard(product.id),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(formatPrice(product.priceKopecks)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductDetailScreen(
                          product: product,
                          cartState: widget.cartState,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      },
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined),
        if (quantity > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              key: AppKeys.cartBadge,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$quantity',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              key: AppKeys.catalogError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: AppKeys.retryButton,
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

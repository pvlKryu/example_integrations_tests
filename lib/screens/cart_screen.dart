import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../keys.dart';
import '../state/cart_state.dart';
import '../utils/money.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.apiClient,
    required this.cartState,
  });

  final ApiClient apiClient;
  final CartState cartState;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _checkoutInProgress = false;
  String? _checkoutError;

  Future<void> _checkout() async {
    if (widget.cartState.isEmpty || _checkoutInProgress) return;

    setState(() {
      _checkoutInProgress = true;
      _checkoutError = null;
    });

    try {
      final items = widget.cartState.items
          .map(
            (item) => {
              'productId': item.product.id,
              'quantity': item.quantity,
              'priceKopecks': item.product.priceKopecks,
            },
          )
          .toList();
      final total = widget.cartState.totalKopecks;
      final order = await widget.apiClient.createOrder(
        items: items,
        totalKopecks: total,
      );
      // После успешного оформления корзина очищается.
      widget.cartState.clear();
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => OrderSuccessScreen(
            orderNumber: order.orderNumber,
            totalKopecks: order.totalKopecks,
          ),
        ),
        (route) => route.isFirst,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _checkoutError = e.message;
        _checkoutInProgress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkoutError = 'Не удалось оформить заказ';
        _checkoutInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.cartState;
    final canCheckout = !cart.isEmpty && !_checkoutInProgress;

    return Scaffold(
      key: AppKeys.cartScreen,
      appBar: AppBar(title: const Text('Корзина')),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      'Корзина пуста',
                      key: AppKeys.cartEmpty,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final id = item.product.id;
                      return Card(
                        key: AppKeys.cartItem(id),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatPrice(item.product.priceKopecks)} × ${item.quantity}',
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    key: AppKeys.decrease(id),
                                    onPressed: () => setState(() {
                                      cart.decrease(id);
                                    }),
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    key: AppKeys.increase(id),
                                    onPressed: () => setState(() {
                                      cart.increase(id);
                                    }),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    key: AppKeys.remove(id),
                                    onPressed: () => setState(() {
                                      cart.remove(id);
                                    }),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Удалить'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Итого: ${formatPrice(cart.totalKopecks)}',
                  key: AppKeys.cartTotal,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_checkoutError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _checkoutError!,
                    key: AppKeys.checkoutError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  key: AppKeys.checkoutButton,
                  // Для пустой корзины кнопка остаётся на экране, но недоступна.
                  onPressed: canCheckout ? _checkout : null,
                  child: _checkoutInProgress
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Оформить заказ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

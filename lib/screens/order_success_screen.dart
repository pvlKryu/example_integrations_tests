import 'package:flutter/material.dart';

import '../keys.dart';
import '../utils/money.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.totalKopecks,
  });

  final String orderNumber;
  final int totalKopecks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppKeys.orderSuccess,
      appBar: AppBar(
        title: const Text('Заказ оформлен'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            Text(
              'Спасибо за заказ!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Номер заказа: $orderNumber',
              key: AppKeys.orderNumber,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Сумма: ${formatPrice(totalKopecks)}',
              key: AppKeys.orderTotal,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            FilledButton(
              key: AppKeys.backToCatalog,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Вернуться в каталог'),
            ),
          ],
        ),
      ),
    );
  }
}

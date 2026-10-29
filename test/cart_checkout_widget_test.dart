import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/api/api_client.dart';
import 'package:study_catalog/keys.dart';
import 'package:study_catalog/screens/cart_screen.dart';
import 'package:study_catalog/state/cart_state.dart';

void main() {
  testWidgets('при пустой корзине оформление недоступно', (tester) async {
    final cart = CartState();
    final api = ApiClient(baseUrl: 'http://127.0.0.1:8080');
    addTearDown(() {
      cart.dispose();
      api.close();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CartScreen(apiClient: api, cartState: cart),
      ),
    );

    expect(find.byKey(AppKeys.cartEmpty), findsOneWidget);
    expect(find.byKey(AppKeys.checkoutButton), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.byKey(AppKeys.checkoutButton),
    );
    expect(button.onPressed, isNull);
  });
}

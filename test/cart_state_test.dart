import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/models/product.dart';
import 'package:study_catalog/state/cart_state.dart';

void main() {
  late CartState cart;
  const product = Product(
    id: 'p1',
    name: 'Учебник Flutter',
    description: 'Описание',
    priceKopecks: 199900,
  );
  const other = Product(
    id: 'p2',
    name: 'Блокнот',
    description: 'Описание',
    priceKopecks: 34900,
  );

  setUp(() {
    cart = CartState();
  });

  tearDown(() {
    cart.dispose();
  });

  test('добавление товара', () {
    cart.addProduct(product);

    expect(cart.items, hasLength(1));
    expect(cart.items.first.product.id, 'p1');
    expect(cart.items.first.quantity, 1);
    expect(cart.totalQuantity, 1);
  });

  test('повторное добавление того же товара увеличивает количество', () {
    cart.addProduct(product);
    cart.addProduct(product);

    expect(cart.items, hasLength(1));
    expect(cart.items.first.quantity, 2);
    expect(cart.totalQuantity, 2);
  });

  test('изменение количества: increase и decrease', () {
    cart.addProduct(product);
    cart.increase('p1');
    expect(cart.items.first.quantity, 2);

    cart.decrease('p1');
    expect(cart.items.first.quantity, 1);

    cart.decrease('p1');
    expect(cart.isEmpty, isTrue);
  });

  test('удаление товара', () {
    cart.addProduct(product);
    cart.addProduct(other);
    cart.remove('p1');

    expect(cart.items, hasLength(1));
    expect(cart.items.first.product.id, 'p2');
  });

  test('расчёт суммы', () {
    cart.addProduct(product);
    cart.addProduct(product);
    cart.addProduct(other);

    expect(cart.totalKopecks, 199900 * 2 + 34900);
  });

  test('очистка после успешного заказа', () {
    cart.addProduct(product);
    cart.addProduct(other);
    cart.clear();

    expect(cart.isEmpty, isTrue);
    expect(cart.totalKopecks, 0);
    expect(cart.totalQuantity, 0);
  });
}

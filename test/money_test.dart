import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/utils/money.dart';

void main() {
  test('formatPrice форматирует копейки в рубли', () {
    expect(formatPrice(199900), '1\u00A0999,00 ₽');
    expect(formatPrice(34900), '349,00 ₽');
    expect(formatPrice(0), '0,00 ₽');
  });
}

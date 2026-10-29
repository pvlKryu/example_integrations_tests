import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'screens/catalog_screen.dart';
import 'state/cart_state.dart';

/// Явные зависимости приложения.
/// Для тестов создаём новый экземпляр на каждый кейс — без singleton.
class AppDependencies {
  AppDependencies({
    ApiClient? apiClient,
    CartState? cartState,
  })  : apiClient = apiClient ?? ApiClient(),
        cartState = cartState ?? CartState();

  final ApiClient apiClient;
  final CartState cartState;

  void dispose() {
    apiClient.close();
    cartState.dispose();
  }
}

class StudyCatalogApp extends StatelessWidget {
  const StudyCatalogApp({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    // MaterialApp не оборачиваем в ListenableBuilder:
    // иначе при каждом изменении корзины сбрасывается Navigator.
    return MaterialApp(
      title: 'Учебный каталог',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      // Без Hero: быстрые переходы в integration_test иначе ломают анимацию.
      builder: (context, child) {
        return HeroControllerScope.none(child: child!);
      },
      home: CatalogScreen(
        apiClient: dependencies.apiClient,
        cartState: dependencies.cartState,
      ),
    );
  }
}

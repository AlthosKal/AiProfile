import 'package:flutter/material.dart';
import '../../core/service/app/auth_service.dart';
import '../../core/exception/global_exception_handler.dart';
import '../../dto/auth/request/login_user_dto.dart';
import '../../route/app_routes.dart';

class LoginController {
  final AuthService _authService;

  // Estados de UI reactivos
  final ValueNotifier<bool> rememberPassword = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  LoginController({AuthService? authService}) : _authService = authService ?? AuthService();

  // Método de login
  Future<void> login({
    required BuildContext context,
    required String nameOrEmail,
    required String password,
  }) async {
    isLoading.value = true;

    final dto = LoginUserDTO(
      nameOrEmail: nameOrEmail.trim(),
      password: password,
    );

    await GlobalExceptionHandler.run(() async {
      await _authService.login(dto);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    isLoading.value = false;
  }

  // Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Cambiar recordar contraseña
  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
  }

  // Liberar recursos
  void dispose() {
    rememberPassword.dispose();
    obscurePassword.dispose();
    isLoading.dispose();
  }
}

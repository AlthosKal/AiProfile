import 'package:ai_profile_ui/core/exception/global_exception_handler.dart';
import 'package:ai_profile_ui/core/service/app/auth_service.dart';
import 'package:ai_profile_ui/dto/auth/request/change_password_dto.dart';
import 'package:ai_profile_ui/provider/toast_helper.dart';
import 'package:ai_profile_ui/route/app_routes.dart';
import 'package:flutter/material.dart';

class ChangePasswordController {
  final AuthService _authService;

  // Estados de UI reactivos
  final ValueNotifier<bool> rememberPassword = ValueNotifier(false);
  final ValueNotifier<bool> obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> obscureConfirmPassword = ValueNotifier(true);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  ChangePasswordController({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<void> changePassword({
    required BuildContext context,
    required String email,
    required String code,
    required String newPassword,
  }) async {
    isLoading.value = true;

    final dto = ChangePasswordDTO(
      email: email,
      code: code,
      newPassword: newPassword,
    );

    await GlobalExceptionHandler.run(
      () async {
        await _authService.changePasswordWithCode(dto);
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);

          ToastHelper.showSuccess(
            context,
            title: 'Cambio de contraseña exitoso',
          );
        }
      },
      onError: (error) {
        ToastHelper.showError(
          context,
          title: 'Error al cambiar la contraseña',
          description: error.toString(),
        );
        isLoading.value = false;
      },
    );
    isLoading.value = false;
  }

  // Toggle para mostrar/ocultar contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle para mostrar/ocultar confirmar contraseña
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Cambiar recordar contraseña
  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
  }

  // Liberar recursos
  void dispose() {
    rememberPassword.dispose();
    obscurePassword.dispose();
    obscureConfirmPassword.dispose();
    isLoading.dispose();
  }
}

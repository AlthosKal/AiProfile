import 'package:ai_profile_ui/core/exception/global_exception_handler.dart';
import 'package:ai_profile_ui/core/service/app/auth_service.dart';
import 'package:ai_profile_ui/dto/auth/request/send_verification_code_dto.dart';
import 'package:ai_profile_ui/provider/toast_helper.dart';
import 'package:ai_profile_ui/route/app_routes.dart';
import 'package:flutter/material.dart';

class SendVerificationCodeController {
  final AuthService _authService;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  SendVerificationCodeController({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<void> sendVerificationCode({
    required BuildContext context,
    required String email,
  }) async {
    isLoading.value = true;

    final dto = SendVerificationCodeDTO(email: email);

    await GlobalExceptionHandler.run(
      () async {
        await _authService.sendVerificationCode(isRegistration: true, dto: dto);

        if (context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.validateVerificationCode,
            arguments: email,
          );
          ToastHelper.showSuccess(
            context,
            title: 'Código de verificación enviado correctamente',
          );
        }
      },
      onError: (error) {
        ToastHelper.showError(
          context,
          title: 'Error al enviar el correo',
          description: error.toString(),
        );
        isLoading.value = false;
      },
    );
    isLoading.value = false;
  }

  void dispose() {
    isLoading.dispose();
  }
}

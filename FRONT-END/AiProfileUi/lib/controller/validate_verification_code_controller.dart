import 'dart:async';

import 'package:ai_profile_ui/core/exception/global_exception_handler.dart';
import 'package:ai_profile_ui/core/service/app/auth_service.dart';
import 'package:ai_profile_ui/dto/auth/request/validate_verification_code_dto.dart';
import 'package:ai_profile_ui/route/app_routes.dart';
import 'package:flutter/material.dart';

class ValidateVerificationCodeController {
  final AuthService _authService;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final List<TextEditingController> codeControllers = List.generate(6, (_)=> TextEditingController());
  int currentStep = 0;
  int timerCount = 120;
  Timer? _timer;
  ValidateVerificationCodeController({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<void> validateVerificationCode({
    required BuildContext context,
    required String email,
    required String code,
  }) async {
    isLoading.value = true;

    final dto = ValidateVerificationCodeDTO(email: email, code: code);

    await GlobalExceptionHandler.run(() async {
      await _authService.validateVerificationCode(dto);
      if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.recoverPassword, arguments: email);
    });
    isLoading.value = false;
  }

  void startTimer(VoidCallback onTick, VoidCallback onFinished) {
    timerCount = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerCount--;
      onTick();
      if (timerCount <= 0) {
        timer.cancel();
        onFinished();
      }
    });
  }

  String formatTime() {
    final minutes = timerCount ~/ 60;
    final seconds = timerCount % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getCodeInput() {
    return codeControllers.map((c) => c.text).join();
  }

  void dispose() {
    isLoading.dispose();
    for (var c in codeControllers) {
      c.dispose();
    }
    _timer?.cancel();
  }
}

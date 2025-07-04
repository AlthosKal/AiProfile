import 'dart:io';

import 'package:ai_profile_ui/core/service/app/profile_service.dart';
import 'package:ai_profile_ui/dto/auth/rest/user_detail_dto.dart';
import 'package:ai_profile_ui/provider/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/exception/global_exception_handler.dart';

class UserDetailsController {
  final ProfileService _profileService;

  // Estados reactivos
  final ValueNotifier<UserDetailDTO?> user = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  UserDetailsController({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  Future<void> fetchUser(BuildContext context) async {
    isLoading.value = true;
    error.value = null;

    await GlobalExceptionHandler.run(
      () async {
        final result = await _profileService.getAuthenticatedUser();
        user.value = result;
      },
      onError: (err) {
        error.value = 'No se pudo cargar el perfil';
        ToastHelper.showError(
          context,
          title: 'Error',
          description: err.toString(),
        );
      },
    );

    isLoading.value = false;
  }

  Future<void> updateImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    isLoading.value = true;

    await GlobalExceptionHandler.run(
      () async {
        final file = File(picked.path);
        await _profileService.updateProfileImage(file);
        await fetchUser(context);
        ToastHelper.showSuccess(context, title: 'Imagen actualizada');
      },
      onError: (err) {
        ToastHelper.showError(
          context,
          title: 'Error al actualizar imagen',
          description: err.toString(),
        );
      },
    );

    isLoading.value = false;
  }

  Future<void> deleteImage(BuildContext context) async {
    isLoading.value = true;

    await GlobalExceptionHandler.run(
      () async {
        await _profileService.deleteProfileImage();
        await fetchUser(context);
        ToastHelper.showSuccess(context, title: 'Imagen eliminada');
      },
      onError: (err) {
        ToastHelper.showError(
          context,
          title: 'Error al eliminar imagen',
          description: err.toString(),
        );
      },
    );

    isLoading.value = false;
  }

  void dispose() {
    user.dispose();
    isLoading.dispose();
    error.dispose();
  }
}

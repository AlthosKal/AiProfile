import 'package:flutter/material.dart';

import '../../dto/auth/rest/user_detail_dto.dart';
import '../core/exception/global_exception_handler.dart';
import '../core/service/app/profile_service.dart';

class HomeController {
  final ValueNotifier<int> selectedIndex = ValueNotifier(0);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<UserDetailDTO?> currentUser = ValueNotifier(null);

  final ProfileService _profileService = ProfileService();

  HomeController() {
    loadCurrentUser();
  }

  void onTabTapped(int index) {
    selectedIndex.value = index;
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;

    await GlobalExceptionHandler.run(
      () async {
        final user = await _profileService.getAuthenticatedUser();
        currentUser.value = user;
      },
      onError: (e) {
        debugPrint('🔴 Error en loadCurrentUser: $e');
        currentUser.value = null;
        isLoading.value = false;
      },
    );

    isLoading.value = false;
  }

  void dispose() {
    selectedIndex.dispose();
    isLoading.dispose();
    currentUser.dispose();
  }
}

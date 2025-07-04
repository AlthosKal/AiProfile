import 'package:ai_profile_ui/core/service/app/profile_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../exception/global_exception_handler.dart';

Future<bool> isAuthenticated() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'Authorization');

  if (token == null || token.isEmpty) return false;

  final profileService = ProfileService();
  bool valid = false;

  await GlobalExceptionHandler.run(
    () async {
      await profileService.getAuthenticatedUser();
      valid = true;
    },
    onError: (_) async {
      await storage.delete(key: 'Authorization');
      valid = false;
    },
  );

  return valid;
}

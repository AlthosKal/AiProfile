import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../dto/auth/request/change_password_dto.dart';
import '../../../dto/auth/request/login_user_dto.dart';
import '../../../dto/auth/request/new_user_dto.dart';
import '../../../dto/auth/request/send_verification_code_dto.dart';
import '../../../dto/auth/request/validate_verification_code_dto.dart';
import '../../../dto/auth/rest/token_response_dto.dart';
import '../../exception/api_response.dart';
import '../api_client.dart';

class AuthService {
  final _api = ApiClient();
  final _storage = const FlutterSecureStorage();

  //Verificar si el servicio puede funcionar correctamente
  bool get isReady => _api.isInitialized;

  Future<TokenResponseDTO> login(LoginUserDTO dto) async {
    final response = await _api.postApp('/auth/login', dto.toJson());

    if (response.statusCode == 200) {
      final json = response.data;
      final apiResponse = ApiResponse<TokenResponseDTO>.fromJson(
        json,
          (data) => TokenResponseDTO.fromJson(data),
      );

      await _storage.write(key: 'Authorization', value: apiResponse.data.token);
      return apiResponse.data;
    } else {
      throw Exception('Login fallido: código ${response.statusCode}, ${response.statusMessage}');
    }
  }

  Future<void> register(NewUserDTO dto) async {
    final response = await _api.postApp('/auth/register', dto.toJson());

    if (response.statusCode != 201) {
      throw Exception('Registro Fallido: : ${response.statusCode}, ${response.statusMessage}');
    }
  }

  Future<void> sendVerificationCode({
    bool isRegistration = false,
    required  SendVerificationCodeDTO dto
  }) async{
    final response = await _api.postApp('/auth/send-verification-code?isRegistration=$isRegistration',dto.toJson());

    if (response.statusCode != 200) {
      throw Exception('Error al enviar el código de Verificación: ${response.statusMessage}, ${response.statusMessage}');
    }
  }

  Future<void> validateVerificationCode(ValidateVerificationCodeDTO dto) async {
    final response = await _api.postApp('/auth/validate-verification-code', dto.toJson());
    if(response.statusCode !=200) {
      throw Exception('Código Invalido: ${response.statusMessage}, ${response.statusMessage}');
    }
  }

  Future<void> changePasswordWithCode(ChangePasswordDTO dto) async {
    final response = await _api.putApp('/auth/change-password', dto.toJson());

    if (response.statusCode != 200){
      throw Exception('Error al cambian la contraseña: ${response.statusCode}, ${response.statusMessage}');
    }
  }

  Future<void> logout() async {
    final response = await _api.postApp('/auth/logout', {});
    if (response.statusCode == 200){
      await _storage.delete(key: 'Authorization');
    } else {
      throw Exception('Error al cerrar sesión: ${response.statusCode}, ${response.statusMessage}');
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await _api.deleteApp('/auth/$userId');

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario: código ${response.statusCode}');
    }
  }
}
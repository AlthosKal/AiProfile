import 'dart:io';

import 'package:dio/dio.dart';

import '../../../dto/auth/rest/image_dto.dart';
import '../../../dto/auth/rest/user_detail_dto.dart';
import '../../exception/api_response.dart';
import '../api_client.dart';

class ProfileService {
  final _api = ApiClient();

  Future<ImageDTO> uploadProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/user/image/add', {formData});

    if (response.statusCode == 200) {
      final json = response.data;
      final apiResponse = ApiResponse<ImageDTO>.fromJson(
        json,
        (data) => ImageDTO.fromJson(data),
      );

      return apiResponse.data;
    } else {
      throw Exception(
        'Error al subir la imagen: código ${response.statusCode}, ${response.statusMessage}',
      );
    }
  }

  Future<ImageDTO> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _api.postApp('/auth/user/image/update', {formData});

    if (response.statusCode == 200) {
      final json = response.data;
      final apiResponse = ApiResponse<ImageDTO>.fromJson(
        json,
        (data) => ImageDTO.fromJson(data),
      );

      return apiResponse.data;
    } else {
      throw Exception(
        'Error al  actualizar la imagen: código ${response.statusCode}, ${response.statusMessage}',
      );
    }
  }

  Future<UserDetailDTO> getAuthenticatedUser() async {
    final response = await _api.getApp('/auth/user/details');

    if (response.statusCode == 200) {
      final json = response.data;
      final apiResponse = ApiResponse<UserDetailDTO>.fromJson(
        json,
        (data) => UserDetailDTO.fromJson(data),
      );

      return apiResponse.data;
    } else {
      throw Exception('Error al obtener los detalles del usuario');
    }
  }

  Future<void> deleteProfileImage() async {
    final response = await _api.deleteApp('/auth/user/image/delete');

    if (response.statusCode != 204) {
      throw Exception(
        'Error al eliminar la imagen: código ${response.statusCode}, ${response.statusMessage}',
      );
    }
  }
}

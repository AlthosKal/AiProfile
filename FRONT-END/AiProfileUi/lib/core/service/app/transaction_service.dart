import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../dto/logic/request/new_transaction_dto.dart';
import '../../../dto/logic/request/update_transaction_dto.dart';
import '../../../dto/logic/rest/get_transaction_dto.dart';
import '../../exception/api_response.dart';
import '../api_client.dart';

class TransactionService {
  final _api = ApiClient();

  Future<List<GetTransactionDTO>> getAllTransactions({
    String? from,
    String? to,
    String? kind,
  }) async {
    final queryParams = <String, dynamic>{};

    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (kind != null) queryParams['kind'] = kind;

    final response = await _api.getApp(
      '/transaction',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<List<GetTransactionDTO>>.fromJson(
        response.data,
        (data) =>
            (data as List)
                .map((item) => GetTransactionDTO.fromJson(item))
                .toList(),
      );
      return apiResponse.data;
    } else {
      throw Exception('Error al obtener transacciones: ${response.statusCode}');
    }
  }

  Future<void> createTransaction(NewTransactionDTO dto) async {
    final response = await _api.postApp('/transaction', dto.toJson());

    if (response.statusCode != 200) {
      throw Exception(
        'Error al crear la transacción: ${response.statusCode} - ${response.statusMessage}',
      );
    }
  }

  Future<List<NewTransactionDTO>> createTransactions(
    List<NewTransactionDTO> dtoList,
  ) async {
    final response = await _api.postApp(
      '/transaction/batch',
      NewTransactionDTO.toListJson(dtoList),
    );

    if (response.statusCode == 200) {
      final apiResponse = ApiResponse<List<NewTransactionDTO>>.fromJson(
        response.data,
        (data) =>
            (data as List).map((e) => NewTransactionDTO.fromJson(e)).toList(),
      );
      return apiResponse.data;
    } else {
      throw Exception(
        'Error al crear transacciones: ${response.statusCode} - ${response.statusMessage}',
      );
    }
  }

  Future<void> updateTransaction(UpdateTransactionDTO dto) async {
    final response = await _api.putApp('/transaction', dto.toJson());

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar la transacción: ${response.statusCode} - ${response.statusMessage}',
      );
    }
  }

  Future<File> exportTransactionsToExcel() async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/transacciones.xlsx';

    // (Opcional) Pedir permisos si estás en Android
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final response = await _api.downloadFile('/transactions/export', savePath);

    if (response.statusCode == 200) {
      return File(savePath);
    } else {
      throw Exception('Error al exportar: ${response.statusCode}');
    }
  }

  Future<void> importTransactionsFromExcel(File excelFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        excelFile.path,
        filename: 'import.xlsx',
      ),
    });

    final response = await _api.postApp('/transactions/import', formData);

    if (response.statusCode != 200) {
      throw Exception('Error al importar: ${response.statusCode}');
    }
  }
}

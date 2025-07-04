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
    final apiResponse = ApiResponse<List<GetTransactionDTO>>.fromJson(
      response.data,
      (data) =>
          (data as List)
              .map((item) => GetTransactionDTO.fromJson(item))
              .toList(),
    );
    return apiResponse.data;
  }

  Future<void> createTransaction(NewTransactionDTO dto) async {
    await _api.postApp('/transaction', dto.toJson());
  }

  Future<List<NewTransactionDTO>> createTransactions(
    List<NewTransactionDTO> dtoList,
  ) async {
    final response = await _api.postApp(
      '/transaction/batch',
      NewTransactionDTO.toListJson(dtoList),
    );
    final apiResponse = ApiResponse<List<NewTransactionDTO>>.fromJson(
      response.data,
      (data) =>
          (data as List).map((e) => NewTransactionDTO.fromJson(e)).toList(),
    );
    return apiResponse.data;
  }

  Future<void> updateTransaction(UpdateTransactionDTO dto) async {
    await _api.putApp('/transaction', dto.toJson());
  }

  Future<void> deleteTransaction(int id) async {
    await _api.deleteApp('/transaction/$id');
  }

  Future<File> exportTransactionsToExcel() async {
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/transacciones.xlsx';

    // (Opcional) Pedir permisos si estás en Android
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
    await _api.downloadFile('/transactions/export', savePath);

    return File(savePath);
  }

  Future<void> importTransactionsFromExcel(File excelFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        excelFile.path,
        filename: 'import.xlsx',
      ),
    });
    await _api.postApp('/transactions/import', formData);
  }
}

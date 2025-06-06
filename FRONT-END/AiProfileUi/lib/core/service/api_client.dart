import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Singleton
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  final _storage = const FlutterSecureStorage();

  late final Dio _dioApp;
  late final Dio _dioChat;

  late final String baseUrlApp;
  late final String baseUrlChat;

  bool _isInitialized = false;

  ApiClient._internal() {
    _initializeUrls();
    _dioApp = _createDio(baseUrlApp);
    _dioChat = _createDio(baseUrlChat);
    _isInitialized = true;
  }

  void _initializeUrls() {
      baseUrlApp = dotenv.get('AI_PROFILE_APP_URL');
      baseUrlChat = dotenv.get('AI_PROFILE_CHAT_URL');
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'Authorization');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Manejo centralizado de errores
        if (e.response?.statusCode == 401) {
          // Redirigir al login
        }
        return handler.next(e);
      },
    ));

    return dio;
  }

  //Verificar si está inicializado
  bool get isInitialized => _isInitialized;

  // Métodos públicos para usar las APIs
  Future<Response> getApp(String path, {Map<String, dynamic>? queryParameters}) =>
      _dioApp.get(path, queryParameters: queryParameters);
  Future<Response> postApp(String path, dynamic data) => _dioApp.post(path, data: data);
  Future<Response> putApp(String path, dynamic data) => _dioApp.put(path, data: data);
  Future<Response> deleteApp(String path) => _dioApp.delete(path);
  Future<Response> downloadFile(String path, String savePath) {
    return _dioApp.download(
      path,
      savePath,
      options: Options(responseType: ResponseType.bytes),
    );
  }


  Future<Response> getChat(String path) => _dioChat.get(path);
  Future<Response> postChat(String path, dynamic data) => _dioChat.post(path, data: data);
  Future<Response> putChat(String path, dynamic data) => _dioChat.put(path, data: data);
  Future<Response> deleteChat(String path) => _dioChat.delete(path);
}

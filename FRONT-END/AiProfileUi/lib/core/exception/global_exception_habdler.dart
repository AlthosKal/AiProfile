typedef AsyncTask<T> = Future<T> Function();

class GlobalExceptionHandler {
  static Future<T> run<T>(AsyncTask<T> task) async {
    try {
      return await task();
    } catch (e, stack) {
      print('🛑 Error global: $e');
      throw Exception('Ocurrió un error inesperado. Intenta de nuevo.');
    }
  }
}

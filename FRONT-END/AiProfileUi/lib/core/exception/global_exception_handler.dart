typedef AsyncTask<T> = Future<T> Function();

class GlobalExceptionHandler {
  static Future<T> run<T>(AsyncTask<T> task) async {
    try {
      return await task();
    } catch (e, stack) {
      print('🛑 Error global: $e');
      print('📍 Stack trace: $stack');

      // Personalizar mensajes según el tipo de error
      String userMessage = _getUserFriendlyMessage(e);
      throw Exception(userMessage);
    }
  }

  static String _getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('lateinitializationerror')) {
      return 'Error de inicialización. Reinicia la aplicación.';
    } else if (errorString.contains('notinitializederror')) {
      return 'Servicio no inicializado. Reinicia la aplicación.';
    } else if (errorString.contains('dio')) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (errorString.contains('timeout')) {
      return 'Tiempo de espera agotado. Intenta de nuevo.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Sesión expirada. Inicia sesión nuevamente.';
    } else if (errorString.contains('forbidden') ||
        errorString.contains('403')) {
      return 'No tienes permisos para realizar esta acción.';
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'Recurso no encontrado.';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return 'Error del servidor. Intenta más tarde.';
    } else {
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
    }
  }
}

import '../../../dto/chat/rest/chat_history_dto.dart';
import '../api_client.dart';

class ChatService {
  final _api = ApiClient();

  Future<List<ChatHistoryDTO>> getHistoryByConversationId(
    String conversationId,
  ) async {
    final response = await _api.getChat('/chat/history/$conversationId');

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is List) {
        return data.map((json) => ChatHistoryDTO.fromJson(json)).toList();
      } else {
        throw Exception('Respuesta inesperada del servidor.');
      }
    } else {
      throw Exception(
        'Error al obtener historial: código ${response.statusCode}, ${response.statusMessage}',
      );
    }
  }
}

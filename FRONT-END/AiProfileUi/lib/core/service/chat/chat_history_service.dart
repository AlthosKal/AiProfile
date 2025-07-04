import '../../../dto/chat/rest/chat_history_dto.dart';
import '../api_client.dart';

class ChatHistoryService {
  final _api = ApiClient();

  Future<List<ChatHistoryDTO>> getAllConversations() async {
    final response = await _api.getChat('/chat/history/user');

    final data = response.data;

    if (data is List) {
      return data.map((json) => ChatHistoryDTO.fromJson(json)).toList();
    }
    throw Exception('Respuesta inesperada del servidor.');
  }

  Future<List<ChatHistoryDTO>> getHistoryByConversationId(
    String conversationId,
  ) async {
    final response = await _api.getChat('/chat/history/$conversationId');

    final data = response.data;

    if (data is List) {
      return data.map((json) => ChatHistoryDTO.fromJson(json)).toList();
    }
    throw Exception('Respuesta inesperada del servidor.');
  }
}

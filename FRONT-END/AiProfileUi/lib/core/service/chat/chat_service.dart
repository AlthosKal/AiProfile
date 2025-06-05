import '../../../dto/chat/request/chat_dto.dart';
import '../../../dto/chat/request/chat_files_dto.dart';
import '../../../dto/chat/request/chat_multipart_dto.dart';
import '../../../dto/chat/rest/chat_response_dto.dart';
import '../../../dto/chat/rest/string_chat_response_dto.dart';
import '../api_client.dart';

class ChatService {
  final _api = ApiClient();

  Future<ChatResponseDTO> askAi(ChatDTO dto) async {
    final response = await _api.postChat('/chat', dto.toJson());

    if (response.statusCode == 200) {
      return ChatResponseDTO.fromJson(response.data);
    } else {
      throw Exception('Error al consultar IA: ${response.statusCode}');
    }
  }

  Future<StringChatResponseDTO> askAiWithUrl(ChatFilesDTO dto) async {
    final response = await _api.postChat('/chat-with-url', dto.toJson());

    if (response.statusCode == 200) {
      return StringChatResponseDTO.fromJson(response.data);
    } else {
      throw Exception('Error al consultar IA: ${response.statusCode}');
    }
  }

  Future<StringChatResponseDTO> askAiWithFile(ChatMultipartDTO dto) async {
    final response = await _api.postChat('/chat-with-file', dto.toJson());

    if (response.statusCode == 200) {
      return StringChatResponseDTO.fromJson(response.data);
    } else {
      throw Exception('Error al consultar IA: ${response.statusCode}');
    }
  }
}
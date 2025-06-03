package com.example.back_end.AiProfileChat.service;

import com.example.back_end.AiProfileChat.dto.*;

import java.util.List;

public interface ChatService {
    AnalysisResponseDTO queryAi(ChatDTO request);
    String queryAi(ChatMultipartDTO request);
    String queryAi(ChatFilesDTO request);
    List<ChatHistoryDTO> getHistoryByConversationId(String conversationId);
}

package com.example.back_end.AiProfileChat.service;

import com.example.back_end.AiProfileChat.dto.request.ChatDTO;
import com.example.back_end.AiProfileChat.dto.request.ChatFilesDTO;
import com.example.back_end.AiProfileChat.dto.request.ChatHistoryDTO;
import com.example.back_end.AiProfileChat.dto.request.ChatMultipartDTO;
import com.example.back_end.AiProfileChat.dto.rest.AnalysisResponseDTO;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

public interface ChatService {
    AnalysisResponseDTO queryAi(ChatDTO request);
    String queryAi(ChatMultipartDTO request);
    String queryAi(ChatFilesDTO request);
    List<ChatHistoryDTO> getHistoryByConversationId(String conversationId);
    List<ChatHistoryDTO> getAllConversationsOfAuthenticatedUser(HttpServletRequest request);
}

package com.example.back_end.AiProfileChat.controller;

import com.example.back_end.AiProfileChat.controller.resource.ChatResource;
import com.example.back_end.AiProfileChat.dto.rest.AnalysisResponseDTO;
import com.example.back_end.AiProfileChat.dto.request.ChatDTO;
import com.example.back_end.AiProfileChat.dto.request.ChatFilesDTO;
import com.example.back_end.AiProfileChat.dto.request.ChatMultipartDTO;
import com.example.back_end.AiProfileChat.dto.rest.ChatResponseDTO;
import com.example.back_end.AiProfileChat.dto.rest.StringChatResponseDTO;
import com.example.back_end.AiProfileChat.service.ChatService;
import com.example.back_end.AiProfileChat.service.functions.ConversationIdService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
public class ChatController implements ChatResource {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatController.class);

    private final ChatService chatService;
    private final ConversationIdService conversationIdService;

    @Override
    @PostMapping(value = "/chat")
    public ResponseEntity<ChatResponseDTO> askAi(@RequestBody @Valid ChatDTO request) {
        if (request.needsConversationId()) {
            request.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", request.getConversationId());
        }

        LOGGER.info("Processing the prompt with {}", request.toString());
        AnalysisResponseDTO analysis = chatService.queryAi(request);

        ChatResponseDTO response = new ChatResponseDTO(request.getConversationId(), analysis);
        return ResponseEntity.ok().body(response);
    }

    @Override
    @PostMapping(value = "/chat-with-url")
    public ResponseEntity<StringChatResponseDTO> askAi(@RequestBody @Valid ChatFilesDTO request) {
        if (request.needsConversationId()) {
            request.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", request.getConversationId());
        }
        LOGGER.info("Processing the files with {}", request.toString());
        String aiResponse = chatService.queryAi(request);

        StringChatResponseDTO response = new StringChatResponseDTO(request.getConversationId(), aiResponse);
        return ResponseEntity.ok().body(response);
    }

    @Override
    @PostMapping(value = "/chat-with-file")
    public ResponseEntity<StringChatResponseDTO> askAi(@ModelAttribute @Valid ChatMultipartDTO request) {
        if (request.needsConversationId()) {
            request.setConversationId(conversationIdService.generateConversationId());
            LOGGER.info("Generated conversationId: {}", request.getConversationId());
        }
        LOGGER.info("Processing the file with {}", request.toString());
        String aiResponse = chatService.queryAi(request);

        StringChatResponseDTO response = new StringChatResponseDTO(request.getConversationId(), aiResponse);
        return ResponseEntity.ok().body(response);
    }
}

package com.example.back_end.AiProfileChat.controller;

import com.example.back_end.AiProfileChat.controller.resource.ChatHistoryResource;
import com.example.back_end.AiProfileChat.dto.request.ChatHistoryDTO;
import com.example.back_end.AiProfileChat.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/chat/history")
@RequiredArgsConstructor
public class ChatHistoryController implements ChatHistoryResource {
    private static final Logger LOGGER = LoggerFactory.getLogger(ChatHistoryController.class);

    private final ChatService chatService;

    @GetMapping("/{conversationId}")
    @Override
    public ResponseEntity<List<ChatHistoryDTO>> getHistory(
            @PathVariable String conversationId) {
        LOGGER.info("Processing history of conversationId {}", conversationId);

        List<ChatHistoryDTO> response = chatService.getHistoryByConversationId(conversationId);
        return ResponseEntity.ok().body(response);
    }
}

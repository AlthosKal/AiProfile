package com.example.back_end.AiProfileChat.controller;

import com.example.back_end.AiProfileChat.controller.resource.ChatResource;
import com.example.back_end.AiProfileChat.dto.AnalysisResponseDTO;
import com.example.back_end.AiProfileChat.dto.ChatDTO;
import com.example.back_end.AiProfileChat.dto.ChatFilesDTO;
import com.example.back_end.AiProfileChat.dto.ChatMultipartDTO;
import com.example.back_end.AiProfileChat.service.ChatService;
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

    @Override
    @PostMapping(value = "/chat")
    public ResponseEntity<AnalysisResponseDTO> askAi(@RequestBody @Valid ChatDTO request) {
        LOGGER.info("Processing the prompt with {}", request.toString());

        AnalysisResponseDTO response = chatService.queryAi(request);
        return ResponseEntity.ok().body(response);
    }

    @Override
    @PostMapping(value = "/chat-with-url")
    public ResponseEntity<String> askAi(@RequestBody @Valid ChatFilesDTO request) {
        LOGGER.info("Processing the files with {}", request.toString());

        String response = chatService.queryAi(request);
        return ResponseEntity.ok().body(response);
    }

    @Override
    @PostMapping(value = "/chat-with-file")
    public ResponseEntity<String> askAi(@ModelAttribute @Valid ChatMultipartDTO request) {
        LOGGER.info("Processing the file with {}", request.toString());

        String response = chatService.queryAi(request);
        return ResponseEntity.ok().body(response);
    }
}

package com.example.back_end.AiProfileChat.dto.rest;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class StringChatResponseDTO {
    private String conversationId;
    private String response;
}

package com.example.back_end.AiProfileChat.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatHistoryDTO {
    private String conversationId;
    private String prompt;
    private String response;
    private LocalDateTime date;

    //Constructor simplificado
    public ChatHistoryDTO(String conversationId, String prompt, String response) {
        this(conversationId, prompt, response, LocalDateTime.now());
    }

}

package com.example.back_end.AiProfileChat.entity;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.Date;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Document(collection = "chat_history")
public class ChatHistory {
    @Id
    private String id;
    private String conversationId;
    private String prompt;
    private String response;
    private LocalDateTime date;

    public ChatHistory(String conversationId, String prompt, String response) {
        this.conversationId = conversationId;
        this.prompt = prompt;
        this.response = response;
    }
}

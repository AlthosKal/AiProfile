package com.example.back_end.AiProfileChat.repository;

import com.example.back_end.AiProfileChat.entity.ChatHistory;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AiHistoryRepository extends MongoRepository<ChatHistory, String> {
    List<ChatHistory> findByConversationId(String conversationId);
    List<ChatHistory> findByUsername(String username);

}

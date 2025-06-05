package com.example.back_end.AiProfileChat.mapper;

import com.example.back_end.AiProfileChat.dto.request.ChatHistoryDTO;
import com.example.back_end.AiProfileChat.entity.ChatHistory;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ChatHistoryMapper {

    ChatHistory toEntity(ChatHistoryDTO chatHistoryDTO);

    ChatHistoryDTO toDTO(ChatHistory chatHistory);

}

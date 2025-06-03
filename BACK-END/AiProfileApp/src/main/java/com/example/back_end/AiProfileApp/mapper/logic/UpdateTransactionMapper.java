package com.example.back_end.AiProfileApp.mapper.logic;

import com.example.back_end.AiProfileApp.dto.logic.UpdateTransactionDTO;
import com.example.back_end.AiProfileApp.entity.Transaction;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UpdateTransactionMapper {
    UpdateTransactionDTO toDTO(Transaction transaction);

    @Mapping(target = "user", ignore = true)
    Transaction toEntity(UpdateTransactionDTO updateTransactionDTO);
}

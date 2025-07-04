package com.example.back_end.AiProfileApp.mapper.logic;

import com.example.back_end.AiProfileApp.dto.logic.TransactionDTO;
import com.example.back_end.AiProfileApp.entity.Transaction;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface GetTransactionMapper {
    TransactionDTO toDTO(Transaction transaction);

    List<TransactionDTO> toDTOList(List<Transaction> transactions);
}

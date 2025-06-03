package com.example.back_end.AiProfileApp.mapper.logic;

import com.example.back_end.AiProfileApp.dto.logic.GetTransactionDTO;
import com.example.back_end.AiProfileApp.entity.Transaction;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface GetTransactionMapper {
    GetTransactionDTO toDTO(Transaction transaction);

    List<GetTransactionDTO> toDTOList(List<Transaction> transactions);
}

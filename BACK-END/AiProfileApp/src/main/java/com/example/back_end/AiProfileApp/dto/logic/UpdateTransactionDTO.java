package com.example.back_end.AiProfileApp.dto.logic;

import com.example.back_end.AiProfileApp.entity.extra.TransactionDescription;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateTransactionDTO {
    private Long id;
    private TransactionDescription description;
    private Integer amount;
}

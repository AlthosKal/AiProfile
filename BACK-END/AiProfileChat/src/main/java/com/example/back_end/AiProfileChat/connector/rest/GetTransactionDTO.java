package com.example.back_end.AiProfileChat.connector.rest;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GetTransactionDTO {
    private TransactionDescription description;
    private Integer amount;
}

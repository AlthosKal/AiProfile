package com.example.back_end.AiProfileChat.connector.rest;

import com.example.back_end.AiProfileChat.enums.TransactionType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class TransactionDescription {
    private String name;
    private Timestamp registrationDate;
    private TransactionType type;
}

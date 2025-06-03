package com.example.back_end.AiProfileApp.entity.extra;

import com.example.back_end.AiProfileApp.enums.TransactionType;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
    @Enumerated(EnumType.STRING)
    private TransactionType type;
}

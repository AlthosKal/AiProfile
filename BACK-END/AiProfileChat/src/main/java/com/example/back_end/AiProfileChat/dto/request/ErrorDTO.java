package com.example.back_end.AiProfileChat.dto.request;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class ErrorDTO {
    private String description;
    private List<String> reasons;
}

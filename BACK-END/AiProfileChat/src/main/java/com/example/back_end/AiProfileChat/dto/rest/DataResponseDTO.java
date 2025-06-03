package com.example.back_end.AiProfileChat.dto.rest;

import lombok.Data;

import java.util.List;

@Data
public class DataResponseDTO {

    private String name;
    private String description;
    private List<ValueResponseDTO> values;

}

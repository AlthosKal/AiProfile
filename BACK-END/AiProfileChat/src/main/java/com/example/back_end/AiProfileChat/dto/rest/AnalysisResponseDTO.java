package com.example.back_end.AiProfileChat.dto.rest;

import lombok.Data;

@Data
public class AnalysisResponseDTO {

    private String response;
    private String analysis;
    private DataResponseDTO data;

}

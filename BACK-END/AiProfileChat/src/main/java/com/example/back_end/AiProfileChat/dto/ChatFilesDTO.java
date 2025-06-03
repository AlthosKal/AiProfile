package com.example.back_end.AiProfileChat.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Data
public class ChatFilesDTO extends ChatDTO {

    @NotNull(message = "You need one file")
    private String[] files;

}

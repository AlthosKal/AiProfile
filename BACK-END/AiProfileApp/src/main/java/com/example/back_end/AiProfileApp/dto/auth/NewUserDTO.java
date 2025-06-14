package com.example.back_end.AiProfileApp.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewUserDTO {
    @NotNull
    private String username;
    @Email
    @NotNull
    public String email;
    @NotNull
    public String password;
}

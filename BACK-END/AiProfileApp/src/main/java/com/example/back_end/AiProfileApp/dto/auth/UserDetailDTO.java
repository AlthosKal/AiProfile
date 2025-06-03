package com.example.back_end.AiProfileApp.dto.auth;

import com.example.back_end.AiProfileApp.dto.image.ImageDTO;
import jakarta.persistence.Version;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserDetailDTO {
    @Version
    private Integer version;
    private String username;
    private String email;
    private ImageDTO image;
}

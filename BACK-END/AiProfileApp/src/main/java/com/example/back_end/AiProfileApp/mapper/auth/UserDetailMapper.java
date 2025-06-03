package com.example.back_end.AiProfileApp.mapper.auth;

import com.example.back_end.AiProfileApp.dto.auth.UserDetailDTO;
import com.example.back_end.AiProfileApp.entity.User;
import com.example.back_end.AiProfileApp.mapper.image.ImageMapper;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring", uses = ImageMapper.class)
public interface UserDetailMapper {
    UserDetailDTO toDto(User user);
}

package com.example.back_end.AiProfileApp.mapper.auth;

import com.example.back_end.AiProfileApp.dto.auth.NewUserDTO;
import com.example.back_end.AiProfileApp.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface NewUserMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "image", ignore = true)
    User toEntity(NewUserDTO newUserDTO);
}

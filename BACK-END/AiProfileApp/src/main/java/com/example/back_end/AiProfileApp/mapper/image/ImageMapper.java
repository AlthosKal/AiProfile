package com.example.back_end.AiProfileApp.mapper.image;

import com.example.back_end.AiProfileApp.dto.image.ImageDTO;
import com.example.back_end.AiProfileApp.entity.Image;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ImageMapper {

    @Mapping(target = "id", ignore = true)

    Image toEntity(ImageDTO imageDTO);

    ImageDTO toDTO(Image image);
}

package com.example.back_end.AiProfileApp.mapper.image;

import com.example.back_end.AiProfileApp.dto.image.ImageDTO;
import com.example.back_end.AiProfileApp.entity.Image;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ImageMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(source = "id_image", target = "imageId")
    Image toEntity(ImageDTO imageDTO);

    @Mapping(target = "id_image", source = "imageId")
    ImageDTO toDTO(Image image);
}

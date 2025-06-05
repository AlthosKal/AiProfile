package com.example.back_end.AiProfileApp.service.image;

import com.example.back_end.AiProfileApp.dto.image.ImageDTO;
import com.example.back_end.AiProfileApp.entity.Image;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface ImageService {
    ImageDTO saveImage(MultipartFile image, HttpServletRequest request, HttpServletResponse response);

    ImageDTO updateImage(MultipartFile image, HttpServletRequest request, HttpServletResponse response);

    void deleteImage(HttpServletRequest request, HttpServletResponse response);

    void removeImage(Image image) throws IOException;
}

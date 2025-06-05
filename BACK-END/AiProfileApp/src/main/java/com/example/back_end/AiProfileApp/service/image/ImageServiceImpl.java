package com.example.back_end.AiProfileApp.service.image;

import com.example.back_end.AiProfileApp.dto.image.ImageDTO;
import com.example.back_end.AiProfileApp.entity.Image;
import com.example.back_end.AiProfileApp.entity.User;
import com.example.back_end.AiProfileApp.jwt.JwtUtil;
import com.example.back_end.AiProfileApp.mapper.image.ImageMapper;
import com.example.back_end.AiProfileApp.repository.ImageRepository;
import com.example.back_end.AiProfileApp.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ImageServiceImpl implements ImageService {
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;
    private final ImageRepository imageRepository;
    private final ImageMapper imageMapper;

    @Override
    public ImageDTO saveImage(MultipartFile image, HttpServletRequest request, HttpServletResponse response) {
        try {
            String username = jwtUtil.extractEmail(request.getHeader("Authorization"));
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            // Verificar si ya tiene una imagen previa
            if (user.getImage() != null) {
                throw new RuntimeException(
                        "El usuario ya tiene una imagen de perfil. Utilice updateImage para actualizarla.");
            }

            // Subir la nueva imagen
            Image newImage = uploadImage(image);
            user.setImage(newImage);
            userRepository.save(user);

            return imageMapper.toDTO(newImage);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al guardar la imagen: " + e.getMessage());
        }
    }

    @Override
    public ImageDTO updateImage(MultipartFile image, HttpServletRequest request, HttpServletResponse response) {
        try {
            String username = jwtUtil.extractEmail(request.getHeader("Authorization"));
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            // Verificar si tiene imagen para actualizar
            if (user.getImage() == null) {
                throw new RuntimeException("El usuario no tiene una imagen de perfil para actualizar.");
            }

            // Eliminar la imagen anterior
            deleteImage(request, response);

            // Subir la nueva imagen
            Image newImage = uploadImage(image);
            user.setImage(newImage);
            userRepository.save(user);

            return imageMapper.toDTO(newImage);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al actualizar la imagen: " + e.getMessage());
        }
    }

    @Override
    public void deleteImage(HttpServletRequest request, HttpServletResponse response) {
        try {
            String username = jwtUtil.extractEmail(request.getHeader("Authorization"));
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            // Verificar si tiene imagen para eliminar
            if (user.getImage() == null) {
                throw new RuntimeException("El usuario no tiene una imagen de perfil para eliminar.");
            }

            // Eliminar la imagen
            Image imageToDelete = user.getImage();
            user.setImage(null);
            userRepository.save(user);

            removeImage(imageToDelete);

            response.setStatus(HttpServletResponse.SC_OK);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al eliminar la imagen: " + e.getMessage());
        }
    }

    public Image uploadImage(MultipartFile file) throws IOException {
        Map uploadResult = cloudinaryService.upload(file);
        String imageUrl = (String) uploadResult.get("url");
        String imageId = (String) uploadResult.get("public_id");
        Image image = Image.builder().name(file.getOriginalFilename()).imageUrl(imageUrl).imageId(imageId).build();
        return imageRepository.save(image);
    }

    @Override
    public void removeImage(Image image) throws IOException {
        cloudinaryService.delete(image.getImageId());
        imageRepository.deleteById(image.getId());
    }
}

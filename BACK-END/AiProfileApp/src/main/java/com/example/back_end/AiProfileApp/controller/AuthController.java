package com.example.back_end.AiProfileApp.controller;

import com.example.back_end.AiProfileApp.dto.auth.*;
import com.example.back_end.AiProfileApp.dto.image.ImageDTO;
import com.example.back_end.AiProfileApp.exception.ApiResponse;
import com.example.back_end.AiProfileApp.jwt.JwtUtil;
import com.example.back_end.AiProfileApp.service.auth.AuthService;
import com.example.back_end.AiProfileApp.service.auth.SendgridService;
import com.example.back_end.AiProfileApp.service.auth.UserService;
import com.example.back_end.AiProfileApp.service.image.ImageService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/v1/auth")
@AllArgsConstructor
public class AuthController {
    private final UserService userService;
    private final AuthService authService;
    private final SendgridService sengridService;
    private final ImageService imageService;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<TokenResponseDTO>> login(@Valid @RequestBody LoginUserDTO loginUserDTO,
            HttpServletRequest request, HttpServletResponse response) {

        TokenResponseDTO tokenResponseDTO = authService.authenticate(loginUserDTO.getNameOrEmail(),
                loginUserDTO.getPassword(), response);

        return ResponseEntity.ok(ApiResponse.ok("Login exitoso", tokenResponseDTO, request.getRequestURI()));
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Void>> register(@Valid @RequestBody NewUserDTO newUserDTO,
            HttpServletRequest request) {

        authService.registerUser(newUserDTO);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Registro exitoso.", null, request.getRequestURI()));
    }

    @PostMapping("/send-verification-code")
    public ResponseEntity<ApiResponse<Void>> sendVerificationCode(@Valid @RequestBody SendVerificationCodeDTO dto,
            @RequestParam(defaultValue = "false") boolean isRegistration, HttpServletRequest request)
            throws IOException {

        sengridService.sendVerificationEmail(dto, isRegistration);
        return ResponseEntity.ok(ApiResponse.ok("Código de verificación enviado", null, request.getRequestURI()));
    }

    @PostMapping("/validate-verification-code")
    public ResponseEntity<ApiResponse<Void>> validateVerificationCode(
            @Valid @RequestBody ValidateVerificationCodeDTO dto, HttpServletRequest request) {

        boolean isValid = sengridService.validateVerificationCode(dto);
        String message = isValid ? "Código de verificación válido" : "Código de verificación inválido";
        return ResponseEntity.ok(ApiResponse.ok(message, null, request.getRequestURI()));
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiResponse<Void>> changePassword(@Valid @RequestBody ChangePasswordDTO dto,
            HttpServletRequest request) {

        if (dto.getCode() == null || dto.getCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Código de verificación es requerido");
        }

        if (!dto.getNewPassword().equals(dto.getConfirmNewPassword())) {
            throw new IllegalArgumentException("No coinciden las contraseñas");
        }

        String result = authService.changePasswordWithVerification(dto);
        return ResponseEntity.ok(ApiResponse.ok(result, null, request.getRequestURI()));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(HttpServletRequest request, HttpServletResponse response) {
        String token = jwtUtil.resolveToken(request);
        if (token == null) {
            throw new IllegalArgumentException("Token no proporcionado");
        }

        authService.logout(token, response);
        return ResponseEntity.ok(ApiResponse.ok("Cierre de sesión exitoso", null, request.getRequestURI()));
    }

    @PostMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) throws IOException {
        userService.deteleUser(new DeleteUserDTO(id));
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/user/image/add")
    public ResponseEntity<ApiResponse<ImageDTO>> uploadProfileImage(@RequestParam("image") MultipartFile image,
            @RequestHeader("Authorization") String token, HttpServletRequest request, HttpServletResponse response) {

        String jwtToken = token.startsWith("Bearer ") ? token.substring(7) : token;
        ImageDTO imageDTO = imageService.saveImage(image, jwtToken, response);
        return new ResponseEntity<>(ApiResponse.ok("Imagen guardada", imageDTO, request.getRequestURI()),
                HttpStatus.CREATED);
    }

    @PutMapping("/user/image/update")
    public ResponseEntity<ApiResponse<ImageDTO>> updateProfileImage(@RequestParam("image") MultipartFile image,
            @RequestHeader("Authorization") String token, HttpServletRequest request, HttpServletResponse response) {

        String jwtToken = token.startsWith("Bearer ") ? token.substring(7) : token;
        ImageDTO imageDTO = imageService.updateImage(image, jwtToken, response);
        return ResponseEntity.ok(ApiResponse.ok("Imagen actualizada", imageDTO, request.getRequestURI()));
    }

    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteProfileImage(@RequestHeader("Authorization") String token,
            HttpServletResponse response) {

        String jwtToken = token.startsWith("Bearer ") ? token.substring(7) : token;
        imageService.deleteImage(jwtToken, response);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/user/details")
    public ResponseEntity<ApiResponse<UserDetailDTO>> getAuthenticatedUser(HttpServletRequest request) {
        UserDetailDTO dto = userService.getUserDetailsDTO();
        return ResponseEntity.ok(ApiResponse.ok("Usuario autenticado", dto, request.getRequestURI()));
    }
}

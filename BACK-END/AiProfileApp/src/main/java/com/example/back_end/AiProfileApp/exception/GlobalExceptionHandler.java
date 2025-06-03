package com.example.back_end.AiProfileApp.exception;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.BindException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    // Errores de validación de campos con @Valid
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationException(MethodArgumentNotValidException ex,
            HttpServletRequest request) {
        String errorMessage = ex.getBindingResult().getAllErrors().stream().map(e -> e.getDefaultMessage())
                .collect(Collectors.joining("; "));

        log.warn("Error de validación: {}", errorMessage);
        return ResponseEntity.badRequest().body(ApiResponse.error(errorMessage, request.getRequestURI()));
    }

    // Errores de validación para @ModelAttribute y otros
    @ExceptionHandler(BindException.class)
    public ResponseEntity<ApiResponse<Void>> handleBindException(BindException ex, HttpServletRequest request) {
        String errorMessage = ex.getBindingResult().getAllErrors().stream().map(e -> e.getDefaultMessage())
                .collect(Collectors.joining("; "));

        log.warn("Error de enlace de datos: {}", errorMessage);
        return ResponseEntity.badRequest().body(ApiResponse.error(errorMessage, request.getRequestURI()));
    }

    // Acceso denegado (útil si usas Spring Security)
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Void>> handleAccessDenied(AccessDeniedException ex, HttpServletRequest request) {
        log.warn("Acceso denegado: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error("Acceso denegado", request.getRequestURI()));
    }

    // Método HTTP no soportado
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResponse<Void>> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex,
            HttpServletRequest request) {
        log.warn("Método no permitido: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(ApiResponse.error("Método no permitido", request.getRequestURI()));
    }

    // Excepciones comunes del dominio
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException ex,
            HttpServletRequest request) {
        log.warn("Argumento inválido: {}", ex.getMessage());
        return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage(), request.getRequestURI()));
    }

    // Errores no controlados
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleAllUncaught(Exception ex, HttpServletRequest request) {
        log.error("Error inesperado", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Ocurrió un error inesperado", request.getRequestURI()));
    }
}

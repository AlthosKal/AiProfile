package com.example.back_end.AiProfileChat.controller;

import io.swagger.v3.oas.annotations.Hidden;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;

// Controlador para redireccionar a la documentación de la API
@Controller
@RequestMapping("/v1/documentation")
public class DocumentationController {
    // Endpoint que redirige a la interfaz Swagger UI para visualizar la documentación de la API
    @Operation(summary = "Redirect to Swagger UI", description = "Redirects to the Swagger UI page for API documentation")
    @GetMapping
    public String redirectToSwaggerUi() {
        return "redirect:/swagger-ui.html";
    }

    // Endpoint oculto que redirige a la documentación OpenAPI en formato JSON o YAML
    @Hidden
    @GetMapping("/openapi")
    public String redirectToOpenApiDocs() {
        return "redirect:/api-docs";
    }
}

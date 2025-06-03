package com.example.back_end.AiProfileApp;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class AiProfileAppApplication {

    public static void main(String[] args) {
        Dotenv dotenv = Dotenv.load();

        // API de SenGrid
        System.setProperty("SENDGRID_API_KEY", dotenv.get("SENDGRID_API_KEY"));
        System.setProperty("EMAIL_SENDGRID", dotenv.get("EMAIL_SENDGRID"));
        System.setProperty("VERIFICATION_EMAIL", dotenv.get("VERIFICATION_EMAIL"));
        System.setProperty("RESET_PASSWORD", dotenv.get("RESET_PASSWORD"));

        // API de Cloudinary
        System.setProperty("CLOUDINARY_NAME", dotenv.get("CLOUDINARY_NAME"));
        System.setProperty("CLOUDINARY_API_KEY", dotenv.get("CLOUDINARY_API_KEY"));
        System.setProperty("CLOUDINARY_API_SECRET", dotenv.get("CLOUDINARY_API_SECRET"));
        // Secret de Jwt
        System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));

        // Configuracion de la base de datos
        System.setProperty("SPRING_DATASOURCE_URL", dotenv.get("SPRING_DATASOURCE_URL"));
        System.setProperty("SPRING_DATASOURCE_USERNAME", dotenv.get("SPRING_DATASOURCE_USERNAME"));
        System.setProperty("SPRING_DATASOURCE_PASSWORD", dotenv.get("SPRING_DATASOURCE_PASSWORD"));

        SpringApplication.run(AiProfileAppApplication.class, args);
    }

}

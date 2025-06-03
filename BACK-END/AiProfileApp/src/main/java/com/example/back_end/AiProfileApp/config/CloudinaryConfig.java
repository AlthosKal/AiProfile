package com.example.back_end.AiProfileApp.config;

import com.cloudinary.Cloudinary;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class CloudinaryConfig {
    @Bean
    public Cloudinary cloudinary() {
        Map<String, Object> valuesMap = new HashMap<>();
        valuesMap.put("cloud_name", System.getenv("CLOUDINARY_NAME"));
        valuesMap.put("api_key", System.getenv("CLOUDINARY_API_KEY"));
        valuesMap.put("api_secret", System.getenv("CLOUDINARY_API_SECRET"));
        return new Cloudinary(valuesMap);
    }
}

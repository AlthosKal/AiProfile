package com.example.back_end.AiProfileChat.controller;

import com.example.back_end.AiProfileChat.controller.resource.ModelResource;
import com.example.back_end.AiProfileChat.enums.Model;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("v1/model")
public class ModelController implements ModelResource {

    private static final Logger LOGGER = LoggerFactory.getLogger(ModelController.class);

    @GetMapping
    public ResponseEntity<List<String>> getAllModels() {
        LOGGER.info("Get available models");
        List<String> models = new ArrayList<>();

        for (Model model : Model.values()) {
            models.add(model.toString());
        }
        return ResponseEntity.ok().body(models);
    }
}

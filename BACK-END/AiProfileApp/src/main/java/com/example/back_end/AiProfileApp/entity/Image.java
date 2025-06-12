package com.example.back_end.AiProfileApp.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "image", indexes = { @Index(name = "idx_image_image_id", columnList = "image_id"), // Cloudinary ID
        @Index(name = "idx_image_url", columnList = "image_url") // Búsquedas por URL
})
public class Image {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    @Column(name = "image_url")
    private String imageUrl;
    @Column(name = "image_id")
    private String imageId;
}

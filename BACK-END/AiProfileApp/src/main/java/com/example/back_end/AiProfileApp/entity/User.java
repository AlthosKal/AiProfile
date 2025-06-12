package com.example.back_end.AiProfileApp.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "appuser", indexes = { @Index(name = "idx_user_username", columnList = "username"), // Ya implícito por
                                                                                                  // unique=true
        @Index(name = "idx_user_email", columnList = "email"), // Ya implícito por unique=true
        @Index(name = "idx_user_name_email", columnList = "username,email"), // Búsquedas combinadas
        @Index(name = "idx_user_password", columnList = "password") // Para autenticación
})
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    @Version
    private Integer version;
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "image_id", referencedColumnName = "id")
    private Image image;
    @Column(unique = true)
    private String username;
    @Column(unique = true)
    private String email;
    @JsonIgnore
    private String password;

}

package com.example.back_end.AiProfileApp.repository;

import com.example.back_end.AiProfileApp.entity.User;
import jakarta.validation.constraints.NotBlank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByUsername(@NotBlank String username);

    Optional<User> findByEmail(String email);

    Boolean existsByEmail(String email);

    boolean existsByUsername(@NotBlank String username);
}

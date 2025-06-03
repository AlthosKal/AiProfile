package com.example.back_end.AiProfileApp.service.auth;

import com.example.back_end.AiProfileApp.dto.auth.DeleteUserDTO;
import com.example.back_end.AiProfileApp.dto.auth.UserDetailDTO;
import com.example.back_end.AiProfileApp.entity.User;
import com.example.back_end.AiProfileApp.mapper.auth.UserDetailMapper;
import com.example.back_end.AiProfileApp.repository.UserRepository;
import com.example.back_end.AiProfileApp.service.image.ImageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Collections;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final ImageService imageService;
    private final UserDetailMapper userDetailMapper;

    @Override
    public UserDetails loadUserByUsername(String nameOrEmail) throws UsernameNotFoundException {
        User user;
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            user = userRepository.findByEmail(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        } else {
            user = userRepository.findByUsername(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        }
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getUsername().toString());

        return new org.springframework.security.core.userdetails.User(user.getEmail(), user.getPassword(),
                Collections.singleton(authority));
    }

    @Override
    public UserDetails loadUserByEmail(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getUsername().toString());

        return new org.springframework.security.core.userdetails.User(user.getEmail(), user.getPassword(),
                Collections.singleton(authority));
    }

    @Override
    public User findByNameOrEmail(String nameOrEmail) {
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            return userRepository.findByEmail(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        } else {
            return userRepository.findByUsername(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        }
    }

    @Override
    public boolean existsByUserName(String name) {
        return userRepository.existsByUsername(name);
    }

    @Override
    public boolean existsByUserEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public void saveUser(User user) {
        userRepository.save(user);
    }

    public User getUserDetails() {
        String nameOrEmail = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByNameOrEmail(nameOrEmail);
    }

    @Override
    public UserDetailDTO getUserDetailsDTO() {
        User user = getUserDetails();
        return userDetailMapper.toDto(user);
    }

    @Override
    public void deteleUser(DeleteUserDTO deleteUserDTOid) throws IOException {
        User user = userRepository.findById(deleteUserDTOid.getId())
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        if (user.getImage() != null) {
            imageService.removeImage(user.getImage());
        }

        try {
            userRepository.delete(user);
        } catch (Exception e) {
            log.error("Error al eliminar el usuario", e);
            throw new RuntimeException(e);
        }
    }
}

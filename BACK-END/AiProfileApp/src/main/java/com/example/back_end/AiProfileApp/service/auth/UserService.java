package com.example.back_end.AiProfileApp.service.auth;

import com.example.back_end.AiProfileApp.dto.auth.DeleteUserDTO;
import com.example.back_end.AiProfileApp.dto.auth.UserDetailDTO;
import com.example.back_end.AiProfileApp.entity.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.io.IOException;

public interface UserService extends UserDetailsService {
    UserDetails loadUserByEmail(String email) throws UsernameNotFoundException;

    User findByNameOrEmail(String nameOrEmail);

    boolean existsByUserName(String username);

    boolean existsByUserEmail(String email);

    void saveUser(User user);

    UserDetailDTO getUserDetailsDTO();

    void deteleUser(DeleteUserDTO id) throws IOException;
}

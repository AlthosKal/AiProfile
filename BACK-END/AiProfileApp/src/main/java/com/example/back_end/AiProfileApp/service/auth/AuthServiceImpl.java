package com.example.back_end.AiProfileApp.service.auth;

import com.example.back_end.AiProfileApp.dto.auth.ChangePasswordDTO;
import com.example.back_end.AiProfileApp.dto.auth.LoginUserDTO;
import com.example.back_end.AiProfileApp.dto.auth.NewUserDTO;
import com.example.back_end.AiProfileApp.dto.auth.TokenResponseDTO;
import com.example.back_end.AiProfileApp.entity.User;
import com.example.back_end.AiProfileApp.exception.exceptions.*;
import com.example.back_end.AiProfileApp.jwt.JwtUtil;
import com.example.back_end.AiProfileApp.mapper.auth.NewUserMapper;
import com.example.back_end.AiProfileApp.repository.UserRepository;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.Optional;

import static com.example.back_end.AiProfileApp.service.auth.SendgridServiceImpl.verificationCodes;

@Service
public class AuthServiceImpl implements AuthService {
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final CookieService cookieService;
    private final UserService userService;
    private final UserRepository userRepository;
    private final TokenBlackListService tokenBlacklistService;
    private final TransactionTemplate transactionTemplate;
    private final NewUserMapper newUserMapper;
    private static final Logger log = LoggerFactory.getLogger(AuthServiceImpl.class);

    @Autowired
    public AuthServiceImpl(UserService userService, PasswordEncoder passwordEncoder, JwtUtil jwtUtil,
            AuthenticationManagerBuilder authenticationManagerBuilder, CookieService cookieService,
            TokenBlackListService tokenBlacklistService, UserRepository userRepository,
            PlatformTransactionManager transactionManager, NewUserMapper newUserMapper) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManagerBuilder = authenticationManagerBuilder;
        this.cookieService = cookieService;
        this.tokenBlacklistService = tokenBlacklistService;
        this.userRepository = userRepository;
        this.newUserMapper = newUserMapper;

        this.transactionTemplate = new TransactionTemplate(transactionManager);
        this.transactionTemplate.setTimeout(30);
        this.transactionTemplate.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
    }

    @Override
    public TokenResponseDTO authenticate(LoginUserDTO dto, HttpServletResponse response) {
        try {
            User user = Optional.ofNullable(userService.findByNameOrEmail(dto.nameOrEmail))
                    .orElseThrow(() -> new AuthException("Credenciales invalidas"));

            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                    user.getEmail(), dto.password);

            Authentication authResult = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
            SecurityContextHolder.getContext().setAuthentication(authResult);

            String jwt = jwtUtil.generateToken(authResult);
            cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);

            return new TokenResponseDTO(jwt, user.getUsername());
        } catch (BadCredentialsException e) {
            throw new AuthException("Credenciales inválidas");
        }
    }

    @Override
    public void registerUser(NewUserDTO newUserDTO) {
        // Validaciones previas
        if (userService.existsByUserName(newUserDTO.getUsername())) {
            throw new AuthException("El nombre de usuario ya existe");
        }

        if (userService.existsByUserEmail(newUserDTO.getEmail())) {
            throw new AuthException("El correo electrónico ya está registrado");
        }

        log.info("Registrando nuevo usuario: {}", newUserDTO.getEmail());

        transactionTemplate.execute(status -> {
            User user = newUserMapper.toEntity(newUserDTO);
            user.setPassword(passwordEncoder.encode(newUserDTO.getPassword()));
            userService.saveUser(user);
            return null;
        });

        // Nota: Cualquier excepción en la transacción será propagada y manejada por GlobalExceptionHandler
    }

    @Override
    public String changePasswordWithVerification(ChangePasswordDTO changePasswordDTO) {
        return transactionTemplate.execute(status -> {
            User user = userRepository.findByEmail(changePasswordDTO.getEmail())
                    .orElseThrow(() -> new AuthException("Usuario no encontrado"));

            user.setPassword(passwordEncoder.encode(changePasswordDTO.getNewPassword()));
            userRepository.save(user);

            verificationCodes.remove(changePasswordDTO.getEmail());
            return "Contraseña actualizada correctamente";
        });
    }

    @Override
    public void logout(String token, HttpServletResponse response) {
        tokenBlacklistService.addToBlacklist(token);
        cookieService.deleteCookie("jwt", response);
        SecurityContextHolder.clearContext();
    }
}
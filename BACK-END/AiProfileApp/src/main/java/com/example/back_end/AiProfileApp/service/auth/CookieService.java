package com.example.back_end.AiProfileApp.service.auth;

import jakarta.servlet.http.HttpServletResponse;

public interface CookieService {
    void addHttpOnlyCookie(String nameOrEmail, String value, int maxAge, HttpServletResponse response);

    void deleteCookie(String name, HttpServletResponse response);
}

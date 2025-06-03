package com.example.back_end.AiProfileApp.service.auth;

public interface TokenBlackListService {
    void addToBlacklist(String token);

    boolean isBlacklisted(String token);
}

package com.example.back_end.AiProfileChat.configuration.ia;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCaching
public class CachingConfiguration {
    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("chats", "history");
    }
}

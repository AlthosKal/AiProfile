package com.example.back_end.AiProfileApp.exception.exceptions;

public class SendgridException extends RuntimeException {
    public SendgridException(String message) {
        super(message);
    }
}

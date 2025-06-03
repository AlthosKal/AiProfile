package com.example.back_end.AiProfileApp.service.logic;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface ExcelService {
    void exportTransactions(HttpServletResponse response);

    void importTransactions(HttpServletRequest request);
}

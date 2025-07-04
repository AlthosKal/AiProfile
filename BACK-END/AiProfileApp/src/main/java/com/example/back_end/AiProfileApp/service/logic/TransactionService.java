package com.example.back_end.AiProfileApp.service.logic;

import com.example.back_end.AiProfileApp.dto.logic.TransactionDTO;
import com.example.back_end.AiProfileApp.dto.logic.NewTransactionDTO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.List;

public interface TransactionService {
    List<TransactionDTO> getTransactions();

    void saveTransaction(NewTransactionDTO transactionDTO, String username);

    TransactionDTO updateTransaction(TransactionDTO transactionDTO, String username);

    void deleteTransaction(Integer id);

    void exportExcel(HttpServletResponse response);

    void importExcel(HttpServletRequest request);
}

package com.example.back_end.AiProfileApp.controller;

import com.example.back_end.AiProfileApp.dto.logic.GetTransactionDTO;
import com.example.back_end.AiProfileApp.dto.logic.NewTransactionDTO;
import com.example.back_end.AiProfileApp.dto.logic.UpdateTransactionDTO;
import com.example.back_end.AiProfileApp.exception.ApiResponse;
import com.example.back_end.AiProfileApp.service.logic.TransactionService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/v1/transaction")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;
    private static final Logger LOGGER = LoggerFactory.getLogger(TransactionController.class);

    @GetMapping
    public ResponseEntity<?> getAllTransactions(HttpServletRequest request, @RequestParam(required = false) String from,
            @RequestParam(required = false) String to, @RequestParam(required = false) String kind) {

        LOGGER.info("Received request for transactions with parameters - from: {}, to: {}, kind: {}", from, to, kind);

        try {
            List<GetTransactionDTO> transactions = transactionService.getTransactions();

            LOGGER.info("Returning {} transactions", transactions.size());

            return ResponseEntity
                    .ok(ApiResponse.ok("Transacciones obtenidas exitosamente", transactions, request.getRequestURI()));

        } catch (Exception e) {
            LOGGER.error("Error getting transactions: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    ApiResponse.error("Error al obtener transacciones: " + e.getMessage(), request.getRequestURI()));
        }
    }

    // Endpoint para crear una sola transacción
    @PostMapping
    public ResponseEntity<?> createTransaction(@RequestBody NewTransactionDTO newTransactionDTO,
            HttpServletRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        transactionService.saveTransaction(newTransactionDTO, username);
        return ResponseEntity.ok(ApiResponse.ok("Transacción creada exitosamente", null, request.getRequestURI()));
    }

    // Endpoint para crear múltiples transacciones
    @PostMapping("/batch")
    public ResponseEntity<?> createTransactions(@RequestBody List<NewTransactionDTO> newTransactionDTOs,
            HttpServletRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        for (NewTransactionDTO dto : newTransactionDTOs) {
            transactionService.saveTransaction(dto, username);
        }

        return ResponseEntity
                .ok(ApiResponse.ok(String.format("%d transacciones creadas exitosamente", newTransactionDTOs.size()),
                        null, request.getRequestURI()));
    }

    @PutMapping
    public ResponseEntity<?> updateTransaction(@RequestBody UpdateTransactionDTO updateTransactionDTO,
            HttpServletRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        UpdateTransactionDTO updatedTransaction = transactionService.updateTransaction(updateTransactionDTO, username);

        if (updatedTransaction == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.<UpdateTransactionDTO> builder().success(false)
                            .message("No se encontró la transacción con el ID proporcionado")
                            .timestamp(LocalDateTime.now()).path(request.getRequestURI()).build());
        }

        return ResponseEntity.ok(
                ApiResponse.ok("Transacción actualizada exitosamente", updatedTransaction, request.getRequestURI()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTransaction(@PathVariable Long id, HttpServletRequest request) {
        transactionService.deleteTransaction(id);
        return ResponseEntity.ok(ApiResponse.ok("Transacción eliminada exitosamente", null, request.getRequestURI()));
    }

    @GetMapping("/export")
    public ResponseEntity<?> exportTransactionsToExcel(HttpServletResponse response) {
        transactionService.exportExcel(response);

        return ResponseEntity.ok(ApiResponse.ok("Datos exportados correctamente",null, null));
    }

    @PostMapping("/import")
    public ResponseEntity<?> importTransactionsFromExcel(HttpServletRequest request, HttpServletResponse response) {
        transactionService.importExcel(request);
        return ResponseEntity
                .ok(ApiResponse.ok("Transacciones importadas exitosamente", null, request.getRequestURI()));
    }
}
package com.example.back_end.AiProfileApp.service.logic;

import com.example.back_end.AiProfileApp.dto.logic.GetTransactionDTO;
import com.example.back_end.AiProfileApp.dto.logic.NewTransactionDTO;
import com.example.back_end.AiProfileApp.dto.logic.UpdateTransactionDTO;
import com.example.back_end.AiProfileApp.entity.Transaction;
import com.example.back_end.AiProfileApp.entity.User;
import com.example.back_end.AiProfileApp.enums.TransactionType;
import com.example.back_end.AiProfileApp.mapper.logic.GetTransactionMapper;
import com.example.back_end.AiProfileApp.mapper.logic.NewTransactionMapper;
import com.example.back_end.AiProfileApp.mapper.logic.UpdateTransactionMapper;
import com.example.back_end.AiProfileApp.repository.TransactionRepository;
import com.example.back_end.AiProfileApp.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TransactionServiceImpl implements TransactionService {
    private static final Logger LOGGER = LoggerFactory.getLogger(TransactionServiceImpl.class);
    private final ExcelService excelService;
    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;
    private final GetTransactionMapper getTransactionMapper;
    private final NewTransactionMapper newTransactionMapper;
    private final UpdateTransactionMapper updateTransactionMapper;

    @Override
    public List<GetTransactionDTO> getTransactions() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        List<Transaction> transactions = transactionRepository.findByUser(user);

        return getTransactionMapper.toDTOList(transactions);
    }

    @Override
    public void saveTransaction(NewTransactionDTO transactionDTO, String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        Transaction transaction = newTransactionMapper.toEntity(transactionDTO);
        transaction.setUser(user);
        transactionRepository.save(transaction);
        newTransactionMapper.toDTO(transaction);
    }

    @Override
    public UpdateTransactionDTO updateTransaction(UpdateTransactionDTO transactionDTO, String username) {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        if (transactionRepository.existsById(transactionDTO.getId())) {
            Transaction transaction = updateTransactionMapper.toEntity(transactionDTO);
            transaction.setUser(user);
            transactionRepository.save(transaction);
            return updateTransactionMapper.toDTO(transaction);
        }
        return null;
    }

    @Override
    public void deleteTransaction(Long id) {
        transactionRepository.deleteById(id);
    }

    @Override
    public void exportExcel(HttpServletResponse response) {
        // Exportar las transacciones a un archivo Excel de un usuario asociado a la autenticación

        excelService.exportTransactions(response);
    }

    @Override
    public void importExcel(HttpServletRequest request) {
        excelService.importTransactions(request);
    }

}

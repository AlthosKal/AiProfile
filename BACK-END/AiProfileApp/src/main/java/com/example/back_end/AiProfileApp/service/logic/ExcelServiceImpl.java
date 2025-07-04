package com.example.back_end.AiProfileApp.service.logic;

import com.example.back_end.AiProfileApp.dto.logic.NewTransactionDTO;
import com.example.back_end.AiProfileApp.entity.Transaction;
import com.example.back_end.AiProfileApp.entity.extra.TransactionDescription;
import com.example.back_end.AiProfileApp.enums.TransactionType;
import com.example.back_end.AiProfileApp.mapper.logic.GetTransactionMapper;
import com.example.back_end.AiProfileApp.mapper.logic.NewTransactionMapper;
import com.example.back_end.AiProfileApp.repository.TransactionRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExcelServiceImpl implements ExcelService {
    private final NewTransactionMapper newTransactionMapper;
    private final TransactionRepository transactionRepository;
    private final GetTransactionMapper getTransactionMapper;

    @Override
    public void exportTransactions(HttpServletResponse response) {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Transacciones");

            // Cabecera
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("Nombre");
            header.createCell(1).setCellValue("Fecha de Registro");
            header.createCell(2).setCellValue("Tipo");
            header.createCell(3).setCellValue("Monto");

            List<Transaction> transactions = transactionRepository.findAll();
            getTransactionMapper.toDTOList(transactions);
            int rowIdx = 1;
            for (Transaction dto : transactions) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(dto.getDescription().getName());
                row.createCell(1).setCellValue(dto.getDescription().getRegistrationDate().toString());
                row.createCell(2).setCellValue(dto.getDescription().getType().name());
                row.createCell(3).setCellValue(dto.getAmount());
            }

            workbook.write(out);
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=transacciones.xlsx");
            response.getOutputStream().write(out.toByteArray());
            response.getOutputStream().flush();
        } catch (IOException e) {
            throw new RuntimeException("Error al exportar transacciones a Excel", e);
        }
    }

    @Override
    public void importTransactions(HttpServletRequest request) {
        try {
            MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest) request;
            MultipartFile file = multipartRequest.getFile("file");
            if (file == null || file.isEmpty()) {
                throw new IllegalArgumentException("Archivo Excel no proporcionado.");
            }

            List<NewTransactionDTO> dtos = new ArrayList<>();
            try (InputStream is = file.getInputStream(); Workbook workbook = new XSSFWorkbook(is)) {
                Sheet sheet = workbook.getSheetAt(0);
                Iterator<Row> rows = sheet.iterator();

                if (rows.hasNext())
                    rows.next(); // saltar encabezado

                while (rows.hasNext()) {
                    Row row = rows.next();

                    String name = row.getCell(0).getStringCellValue();
                    String timestampStr = row.getCell(1).getStringCellValue();
                    String typeStr = row.getCell(2).getStringCellValue();
                    int amount = (int) row.getCell(3).getNumericCellValue();

                    TransactionDescription desc = new TransactionDescription();
                    desc.setName(name);
                    desc.setRegistrationDate(Timestamp.valueOf(timestampStr));
                    desc.setType(TransactionType.valueOf(typeStr));

                    NewTransactionDTO dto = new NewTransactionDTO(desc, amount);
                    dtos.add(dto);
                }
            }

            for (NewTransactionDTO dto : dtos) {
                Transaction transaction = newTransactionMapper.toEntity(dto);
                transactionRepository.save(transaction);
                newTransactionMapper.toDTO(transaction);
            }

        } catch (Exception e) {
            throw new RuntimeException("Error al importar archivo Excel", e);
        }
    }
}

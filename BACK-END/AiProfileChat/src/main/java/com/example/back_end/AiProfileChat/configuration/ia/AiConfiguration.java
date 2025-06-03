package com.example.back_end.AiProfileChat.configuration.ia;

import com.example.back_end.AiProfileChat.connector.AiProfileAppConnector;
import com.example.back_end.AiProfileChat.service.BalanceOverTimeFunction;
import com.example.back_end.AiProfileChat.service.IncomesAndExpensesByPeriodFunction;
import org.springframework.ai.model.function.FunctionCallback;
import org.springframework.ai.model.function.FunctionCallbackWrapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AiConfiguration {
    final AiProfileAppConnector aiProfileAppConnector;

    public AiConfiguration(AiProfileAppConnector aiProfileAppConnector) {
        this.aiProfileAppConnector = aiProfileAppConnector;
    }

    @Bean(name = "incomesAndExpensesByPeriodFunction")
    public FunctionCallback incomesAndExpensesByPeriodFunction() {
        return FunctionCallbackWrapper.builder(new IncomesAndExpensesByPeriodFunction(aiProfileAppConnector))
                .withName("IncomesAndExpensesByPeriod") // Nombre técnico que usa OpenAI
                .withDescription("Returns total incomes and expenses grouped by month for a given period") // Descripción para el modelo
                .build();
    }

    @Bean(name = "balanceOverTimeFunction")
    public FunctionCallback balanceOverTimeFunction() {
        return FunctionCallbackWrapper.builder(new BalanceOverTimeFunction(aiProfileAppConnector))
                .withName("BalanceOverTime")
                .withDescription("Calculates the financial balance (incomes minus expenses) grouped by day or week over a given time period.")
                .build();
    }
}
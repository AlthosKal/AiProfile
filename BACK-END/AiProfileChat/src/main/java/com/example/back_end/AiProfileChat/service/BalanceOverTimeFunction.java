package com.example.back_end.AiProfileChat.service;

import com.example.back_end.AiProfileChat.connector.AiProfileAppConnector;
import com.example.back_end.AiProfileChat.connector.rest.GetTransactionDTO;
import com.example.back_end.AiProfileChat.exception.ApiResponse;
import com.fasterxml.jackson.annotation.JsonClassDescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;

import java.util.List;
import java.util.function.Function;

public class BalanceOverTimeFunction implements Function<BalanceOverTimeFunction.Request, ApiResponse<List<GetTransactionDTO>>> {

    @JsonClassDescription("Request for balance over time calculation")
    public record Request(
            @JsonProperty(required = true, value = "from")
            @JsonPropertyDescription("Start date in YYYY-MM-DD format")
            String from,

            @JsonProperty(required = true, value = "to")
            @JsonPropertyDescription("End date in YYYY-MM-DD format")
            String to,

            @JsonProperty(required = true, value = "kind")
            @JsonPropertyDescription("Type of balance calculation: 'daily' or 'weekly'")
            String kind
    ) {}
    private final AiProfileAppConnector connector;

    public BalanceOverTimeFunction(AiProfileAppConnector connector) {
        this.connector = connector;
    }

    @Override
    public ApiResponse<List<GetTransactionDTO>> apply(Request request) {
        return connector.balanceOverTimeFunction(request.from(), request.to(), request.kind());
    }
}
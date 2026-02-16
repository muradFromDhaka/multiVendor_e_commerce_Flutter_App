package com.abc.SpringSecurityExample.DTOs.projectDtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderRequestDto {
    @NotNull
    private String userName;

    @NotNull
    private List<OrderItemRequestDTO> items;
}

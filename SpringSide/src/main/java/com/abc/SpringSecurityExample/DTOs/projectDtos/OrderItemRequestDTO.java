package com.abc.SpringSecurityExample.DTOs.projectDtos;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemRequestDTO {

    @NotNull
    private Long productId;

    @NotNull
    private Long vendorId;

    @Min(1)
    private int quantity;

    @NotNull
    private BigDecimal unitPrice;

}

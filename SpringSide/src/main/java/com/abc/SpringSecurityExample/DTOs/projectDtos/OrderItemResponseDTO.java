package com.abc.SpringSecurityExample.DTOs.projectDtos;

import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemResponseDTO {

    private Long id;
    private String productName;
    private BigDecimal unitPrice;
    private int quantity;
    private BigDecimal subTotal; // unitPrice * quantity
    private String vendorName;


}

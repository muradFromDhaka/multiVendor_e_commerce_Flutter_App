package com.abc.SpringSecurityExample.DTOs.projectDtos;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class CartItemResponse {
    private Long itemId;
    private Long productId;
    private String productName;
    private Integer quantity;
    private BigDecimal price;
    private BigDecimal total; // Total price for this item (quantity * price)
    private String imageUrl;
}


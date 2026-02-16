package com.abc.SpringSecurityExample.DTOs.projectDtos;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CartDto {

    private Long cartId;
    private List<ItemDto> items;
    private BigDecimal totalAmount;


}

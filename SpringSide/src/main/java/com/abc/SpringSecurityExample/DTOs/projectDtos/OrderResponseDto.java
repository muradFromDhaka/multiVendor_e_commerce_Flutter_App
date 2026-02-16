package com.abc.SpringSecurityExample.DTOs.projectDtos;

import com.abc.SpringSecurityExample.enums.OrderStatus;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderResponseDto {


    private Long id;
    private String userName;
    private BigDecimal totalPrice;
    private String orderStatus;
    private List<OrderItemResponseDTO> items;


}


package com.abc.SpringSecurityExample.mapper;

import com.abc.SpringSecurityExample.DTOs.projectDtos.*;
import com.abc.SpringSecurityExample.entity.*;
import com.abc.SpringSecurityExample.enums.OrderStatus;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

public class OrderMapper {

    // -------------------------------
    // RequestDTO -> Entity
    // -------------------------------
    public static Order toOrderEntity(OrderRequestDto request, User user,
                                      List<Product> products, List<Vendor> vendors) {

        Order order = new Order();
        order.setUser(user);
        order.setOrderStatus(OrderStatus.PENDING); // default
        order.setOrderItems(
                request.getItems().stream().map(itemReq -> {
                    OrderItem item = new OrderItem();

                    Product product = products.stream()
                            .filter(p -> p.getId().equals(itemReq.getProductId()))
                            .findFirst()
                            .orElseThrow(() -> new RuntimeException("Product not found"));

                    Vendor vendor = vendors.stream()
                            .filter(v -> v.getId().equals(itemReq.getVendorId()))
                            .findFirst()
                            .orElseThrow(() -> new RuntimeException("Vendor not found"));

                    item.setProduct(product);
                    item.setVendor(vendor);
                    item.setQuantity(itemReq.getQuantity());
                    item.setUnitPrice(product.getPrice());
                    item.setOrder(order); // set parent

                    return item;
                }).collect(Collectors.toList())
        );

        // Calculate totalPrice
        BigDecimal totalPrice = order.getOrderItems().stream()
                .map(i -> i.getUnitPrice().multiply(BigDecimal.valueOf(i.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        order.setTotalPrice(totalPrice);

        return order;
    }

    // -------------------------------
    // Entity -> ResponseDTO
    // -------------------------------
    public static OrderResponseDto toOrderResponseDto(Order order) {

        OrderResponseDto dto = new OrderResponseDto();
        dto.setId(order.getId());
        dto.setUserName(order.getUser().getUserName());
        dto.setTotalPrice(order.getTotalPrice());
        dto.setOrderStatus(order.getOrderStatus().name());

        List<OrderItemResponseDTO> items = order.getOrderItems().stream()
                .map(item -> {
                    OrderItemResponseDTO itemDTO = new OrderItemResponseDTO();
                    itemDTO.setId(item.getId());
                    itemDTO.setProductName(item.getProduct().getName());
                    itemDTO.setUnitPrice(item.getUnitPrice());
                    itemDTO.setQuantity(item.getQuantity());
                    itemDTO.setSubTotal(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                    itemDTO.setVendorName(item.getVendor().getShopName());
                    return itemDTO;
                }).collect(Collectors.toList());

        dto.setItems(items);

        return dto;
    }


    public static OrderItemResponseDTO mapOrderItemToDto(OrderItem item) {
        OrderItemResponseDTO dto = new OrderItemResponseDTO();
        dto.setId(item.getId());
        dto.setProductName(item.getProduct().getName());
        dto.setUnitPrice(item.getUnitPrice());
        dto.setQuantity(item.getQuantity());
        dto.setSubTotal(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
        dto.setVendorName(item.getVendor().getShopName());
        return dto;
    }


}

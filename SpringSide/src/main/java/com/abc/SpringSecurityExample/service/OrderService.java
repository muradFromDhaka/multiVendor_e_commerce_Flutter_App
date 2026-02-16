package com.abc.SpringSecurityExample.service;

import com.abc.SpringSecurityExample.DTOs.projectDtos.*;
import com.abc.SpringSecurityExample.entity.*;
import com.abc.SpringSecurityExample.enums.OrderStatus;
import com.abc.SpringSecurityExample.mapper.OrderMapper;
import com.abc.SpringSecurityExample.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final VendorRepository vendorRepository;
    private final VendorService vendorService;

    // -------------------------------
    // Create Order
    // -------------------------------
    @Transactional
    public OrderResponseDto createOrder(OrderRequestDto request) {

        User user = userRepository.findById(request.getUserName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Product> products = productRepository.findAllById(
                request.getItems().stream().map(OrderItemRequestDTO::getProductId).toList()
        );

        List<Vendor> vendors = vendorRepository.findAllById(
                request.getItems().stream().map(OrderItemRequestDTO::getVendorId).toList()
        );

        Order order = OrderMapper.toOrderEntity(request, user, products, vendors);

        orderRepository.save(order);

        return OrderMapper.toOrderResponseDto(order);
    }

    // -------------------------------
    // Get Order by ID
    // -------------------------------
    @Transactional(readOnly = true)
    public OrderResponseDto getOrderById(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        return OrderMapper.toOrderResponseDto(order);
    }

    // -------------------------------
    // Get Orders by User
    // -------------------------------
    @Transactional(readOnly = true)
    public List<OrderResponseDto> getOrdersForLoggedInUser() {
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findById(userName)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<Order> orders = orderRepository.findByUser(user);

        return orders.stream()
                .map(OrderMapper::toOrderResponseDto)
                .toList();
    }


    public List<OrderResponseDto> getOrdersForLoggedInVendor() {
        Vendor vendor = vendorService.getLoggedInVendor(); // SecurityContextHolder দিয়ে logged-in vendor
        return orderItemRepository.findOrdersByVendorId(vendor.getId())
                .stream()
                .map(OrderMapper::toOrderResponseDto)
                .toList();
    }

    public List<OrderItem> getItemsForLoggedInVendor() {
        Vendor vendor = vendorService.getLoggedInVendor();
        return orderItemRepository.findByVendor(vendor);
    }

    public Double getRevenueForLoggedInVendor() {
        Vendor vendor = vendorService.getLoggedInVendor();
        return orderItemRepository.findByVendor(vendor)
                .stream()
                .mapToDouble(i -> i.getUnitPrice().doubleValue() * i.getQuantity())
                .sum();
    }

    // -------------------------------
    // Get all OrderItems for a Product
    // -------------------------------
    @Transactional(readOnly = true)
    public List<OrderItem> getItemsByProduct(Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        return orderItemRepository.findByProduct(product);
    }

    // -------------------------------
    // Get all items in a specific Order
    // -------------------------------
    @Transactional(readOnly = true)
    public List<OrderItem> getItemsByOrder(Long orderId) {
        return orderItemRepository.findByOrderId(orderId);
    }

    // -------------------------------
    // Get vendor-specific order items in an order
    // -------------------------------
    @Transactional(readOnly = true)
    public List<OrderItem> getVendorItemsInOrder(Long vendorId, Long orderId) {
        return orderItemRepository.findByVendorIdAndOrderId(vendorId, orderId);
    }

    // -------------------------------
    // Get vendor revenue
    // -------------------------------
    @Transactional(readOnly = true)
    public Double getVendorRevenue(Long vendorId) {
        Vendor vendor = vendorRepository.findById(vendorId)
                .orElseThrow(() -> new RuntimeException("Vendor not found"));
        return orderItemRepository.totalRevenueByVendor(vendor);
    }


}

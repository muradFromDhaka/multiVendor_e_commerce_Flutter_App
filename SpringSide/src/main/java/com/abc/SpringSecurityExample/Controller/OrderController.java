package com.abc.SpringSecurityExample.Controller;

import com.abc.SpringSecurityExample.DTOs.projectDtos.*;
import com.abc.SpringSecurityExample.entity.OrderItem;
import com.abc.SpringSecurityExample.enums.OrderStatus;
import com.abc.SpringSecurityExample.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // -------------------------------
    // Create Order
    // -------------------------------
    @PostMapping
    public ResponseEntity<OrderResponseDto> createOrder(@RequestBody OrderRequestDto request) {
        OrderResponseDto response = orderService.createOrder(request);
        return ResponseEntity.ok(response);
    }

    // -------------------------------
    // Get Order by ID
    // -------------------------------
    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponseDto> getOrderById(@PathVariable Long orderId) {
        OrderResponseDto response = orderService.getOrderById(orderId);
        return ResponseEntity.ok(response);
    }

    // -------------------------------
    // Get Orders by User
    // -------------------------------
    @GetMapping("/me")
    public ResponseEntity<List<OrderResponseDto>> getMyOrders() {
        List<OrderResponseDto> orders = orderService.getOrdersForLoggedInUser();
        return ResponseEntity.ok(orders);
    }

    // Logged-in vendor-এর সব orders
    @GetMapping("/vendor/me")
    public ResponseEntity<List<OrderResponseDto>> getMyVendorOrders() {
        List<OrderResponseDto> orders = orderService.getOrdersForLoggedInVendor();
        return ResponseEntity.ok(orders);
    }

    // Logged-in vendor-এর সব order items
    @GetMapping("/vendor/me/items")
    public ResponseEntity<List<OrderItem>> getMyVendorOrderItems() {
        List<OrderItem> items = orderService.getItemsForLoggedInVendor();
        return ResponseEntity.ok(items);
    }

    // Logged-in vendor-এর revenue
    @GetMapping("/vendor/me/revenue")
    public ResponseEntity<Double> getMyVendorRevenue() {
        Double revenue = orderService.getRevenueForLoggedInVendor();
        return ResponseEntity.ok(revenue);
    }


    // -------------------------------
    // Get all OrderItems for a Product
    // -------------------------------
    @GetMapping("/product/{productId}/items")
    public ResponseEntity<List<OrderItem>> getItemsByProduct(@PathVariable Long productId) {
        List<OrderItem> items = orderService.getItemsByProduct(productId);
        return ResponseEntity.ok(items);
    }

    // -------------------------------
    // Get all items in a specific Order
    // -------------------------------
    @GetMapping("/{orderId}/items")
    public ResponseEntity<List<OrderItem>> getItemsByOrder(@PathVariable Long orderId) {
        List<OrderItem> items = orderService.getItemsByOrder(orderId);
        return ResponseEntity.ok(items);
    }

    // -------------------------------
    // Get vendor-specific order items in an order
    // -------------------------------
    @GetMapping("/vendor/{vendorId}/order/{orderId}/items")
    public ResponseEntity<List<OrderItem>> getVendorItemsInOrder(
            @PathVariable Long vendorId,
            @PathVariable Long orderId
    ) {
        List<OrderItem> items = orderService.getVendorItemsInOrder(vendorId, orderId);
        return ResponseEntity.ok(items);
    }

    // -------------------------------
    // Get vendor revenue
    // -------------------------------
    @GetMapping("/vendor/{vendorId}/revenue")
    public ResponseEntity<Double> getVendorRevenue(@PathVariable Long vendorId) {
        Double revenue = orderService.getVendorRevenue(vendorId);
        return ResponseEntity.ok(revenue);
    }
}

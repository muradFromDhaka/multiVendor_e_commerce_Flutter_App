package com.abc.SpringSecurityExample.Controller;


import com.abc.SpringSecurityExample.DTOs.projectDtos.CartDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.CartItemRequest;
import com.abc.SpringSecurityExample.service.CartService;
import com.abc.SpringSecurityExample.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;
    private final UserService userService;

    // Get the cart of the current user
    @GetMapping
    public ResponseEntity<CartDto> getCart() {
        CartDto cartDto = cartService.getCart();
        return ResponseEntity.ok(cartDto);
    }

    // Add an item to the cart of the current user
    @PostMapping("/add")
    public ResponseEntity<CartDto> addItemToCart(@Valid @RequestBody CartItemRequest request) {
        CartDto cartDto = cartService.addItemToCart(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(cartDto);
    }



    // Update a cart item for the current user
    @PutMapping("/update/{cartItemId}")
    public ResponseEntity<CartDto> updateCartItem(
            @PathVariable Long cartItemId,
            @Valid @RequestBody CartItemRequest request) {
        CartDto cartDto = cartService.updateCartItem(cartItemId, request);
        return ResponseEntity.ok(cartDto);
    }

    // Remove a cart item for the current user
    @DeleteMapping("/remove/{cartItemId}")
    public ResponseEntity<Void> removeCartItem(@PathVariable Long cartItemId) {
        cartService.removeCartItem(cartItemId);
        return ResponseEntity.noContent().build();
    }
}

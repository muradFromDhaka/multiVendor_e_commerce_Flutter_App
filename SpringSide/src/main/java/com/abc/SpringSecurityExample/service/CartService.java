package com.abc.SpringSecurityExample.service;

import com.abc.SpringSecurityExample.DTOs.projectDtos.CartDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.CartItemRequest;
import com.abc.SpringSecurityExample.DTOs.projectDtos.ItemDto;
import com.abc.SpringSecurityExample.Util.NotFoundException;
import com.abc.SpringSecurityExample.entity.Cart;
import com.abc.SpringSecurityExample.entity.CartItem;
import com.abc.SpringSecurityExample.entity.Product;
import com.abc.SpringSecurityExample.entity.User;
import com.abc.SpringSecurityExample.repository.CartRepository;
import com.abc.SpringSecurityExample.repository.ProductRepository;
import com.abc.SpringSecurityExample.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CartService {

    private final CartRepository cartRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    // ===========================================
    // Get Current Logged-in User
    // ===========================================
    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth == null || !auth.isAuthenticated()
                || auth instanceof AnonymousAuthenticationToken) {
            throw new NotFoundException.UnauthorizedException("User not logged in");
        }

        String username = auth.getName();
        return userRepository.findById(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }


    // ===========================================
    // Get Cart for Logged-in User
    // ===========================================
    public CartDto getCart() {
        User currentUser = getCurrentUser();
        Cart cart = cartRepository.findByUser(currentUser)
                .orElseGet(() -> createNewCartForUser(currentUser));

        cart.calculateTotalAmount(); // Calculate total
        return mapCartToDto(cart);
    }

    // ===========================================
    // Add Item to Cart
    // ===========================================
    public CartDto addItemToCart(CartItemRequest request) {
        User currentUser = getCurrentUser();


        Cart cart = cartRepository.findByUser(currentUser)
                .orElseGet(() -> createNewCartForUser(currentUser));

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Optional<CartItem> existingItem = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(product.getId()))
                .findFirst();

        CartItem cartItem;

        if (existingItem.isEmpty()) {
            cartItem = new CartItem();
            cartItem.setProduct(product);
            cartItem.setQuantity(request.getQuantity());
            cartItem.setCart(cart);

            // Set price & totalPrice
            cartItem.setPrice(product.getPrice());
            cartItem.setTotalPrice(product.getPrice().multiply(new BigDecimal(request.getQuantity())));

            cart.getItems().add(cartItem);
        } else {
            cartItem = existingItem.get();
            int newQuantity = cartItem.getQuantity() + request.getQuantity();
            cartItem.setQuantity(newQuantity);

            // Update price & totalPrice
            cartItem.setPrice(product.getPrice());
            cartItem.setTotalPrice(product.getPrice().multiply(new BigDecimal(newQuantity)));
        }

        cart.calculateTotalAmount(); // Update cart total
        cartRepository.save(cart);
        return mapCartToDto(cart);
    }

    // ===========================================
    // Update Cart Item Quantity
    // ===========================================
    public CartDto updateCartItem(Long cartItemId, CartItemRequest request) {
        Cart cart = getCartEntity();

        CartItem cartItem = cart.getItems().stream()
                .filter(item -> item.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found"));

        cartItem.setQuantity(request.getQuantity());
        cartItem.setPrice(cartItem.getProduct().getPrice());
        cartItem.setTotalPrice(cartItem.getProduct().getPrice()
                .multiply(new BigDecimal(request.getQuantity())));

        cart.calculateTotalAmount();
        cartRepository.save(cart);
        return mapCartToDto(cart);
    }

    // ===========================================
    // Remove Cart Item
    // ===========================================
    public void removeCartItem(Long cartItemId) {
        Cart cart = getCartEntity();

        CartItem cartItem = cart.getItems().stream()
                .filter(item -> item.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Cart item not found"));

        cartItem.setCart(null);
        cart.getItems().remove(cartItem);

        cart.calculateTotalAmount();
        cartRepository.save(cart);
    }

    // ===========================================
    // Helper: Create new cart for user
    // ===========================================
    private Cart createNewCartForUser(User user) {
        Cart cart = new Cart();
        cart.setUser(user);
        cart.setTotalAmount(BigDecimal.ZERO);
        return cartRepository.save(cart);
    }

    // ===========================================
    // Helper: Map Cart Entity to DTO
    // ===========================================
    private CartDto mapCartToDto(Cart cart) {
        CartDto cartDto = new CartDto();
        cartDto.setCartId(cart.getId());
        cartDto.setTotalAmount(cart.getTotalAmount());

        List<ItemDto> itemDtos = cart.getItems().stream().map(item -> {
            ItemDto itemDto = new ItemDto();
            itemDto.setItemId(item.getId());
            itemDto.setProductId(item.getProduct().getId());
            itemDto.setProductName(item.getProduct().getName());
            itemDto.setQuantity(item.getQuantity());
            itemDto.setPrice(item.getPrice());
            itemDto.setTotal(item.getTotalPrice());

            try {
                List<String> images = item.getProduct().getImageUrls();
                if (images != null && !images.isEmpty()) {
                    itemDto.setImageUrl(images.get(0));
                }
            } catch (Exception e) {
                System.out.println("Error accessing image: " + e.getMessage());
            }

            return itemDto;
        }).collect(Collectors.toList());

        cartDto.setItems(itemDtos);
        return cartDto;
    }

    // ===========================================
    // Helper: Get Cart Entity
    // ===========================================
    public Cart getCartEntity() {
        User currentUser = getCurrentUser();
        return cartRepository.findByUser(currentUser)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
    }
}

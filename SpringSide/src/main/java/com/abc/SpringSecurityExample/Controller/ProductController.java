package com.abc.SpringSecurityExample.Controller;

import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductResponseDto;
import com.abc.SpringSecurityExample.entity.Product;
import com.abc.SpringSecurityExample.entity.Vendor;
import com.abc.SpringSecurityExample.enums.ProductStatus;
import com.abc.SpringSecurityExample.repository.VendorRepository;
import com.abc.SpringSecurityExample.service.ProductService;
import com.abc.SpringSecurityExample.service.VendorService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final VendorRepository vendorRepository;

    // ---------------- CREATE PRODUCT ----------------
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ProductResponseDto> createProduct(
            @RequestPart("product") ProductRequestDto dto,
            @RequestPart(value = "images", required = false) MultipartFile[] images
    ) throws IOException {
        ProductResponseDto created = productService.createProduct(dto, images);
        return ResponseEntity.ok(created);
    }

//    // ---------------- UPDATE PRODUCT ----------------
//    @PutMapping("/{id}")
//    public ResponseEntity<ProductResponseDto> updateProduct(
//            @PathVariable Long id,
//            @RequestPart("product") ProductRequestDto dto,
//            @RequestPart(value = "images", required = false) MultipartFile[] images
//    ) throws IOException {
//        ProductResponseDto updated = productService.updateProduct(id, dto, images);
//        return ResponseEntity.ok(updated);
//    }


    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ProductResponseDto updateProduct(
            @PathVariable Long id,
            @RequestPart("product") ProductRequestDto dto,
            @RequestPart(value = "images", required = false) MultipartFile[] images
    ) throws IOException {
        return productService.updateProduct(id, dto, images);
    }


    // ---------------- GET PRODUCT BY ID ----------------
    @GetMapping("/{id}")
    public ResponseEntity<ProductResponseDto> getProduct(@PathVariable Long id) {
        ProductResponseDto product = productService.getProduct(id);
        return ResponseEntity.ok(product);
    }

    // ---------------- DELETE PRODUCT ----------------
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteProduct(@PathVariable Long id) throws IOException {
        productService.deleteProduct(id);
        return ResponseEntity.ok("Product deleted successfully");
    }

    // ---------------- LIST ALL PRODUCTS ----------------
    @GetMapping
    public ResponseEntity<List<ProductResponseDto>> listAllProducts() {
        List<ProductResponseDto> products = productService.listAllProducts();
        return ResponseEntity.ok(products);
    }

    // ---------------- POPULAR / LATEST / DISCOUNTED / TRENDING ----------------
    @GetMapping("/most-popular")
    public ResponseEntity<List<ProductResponseDto>> getMostPopular(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(productService.getMostPopularProducts(limit));
    }

    @GetMapping("/latest")
    public ResponseEntity<List<ProductResponseDto>> getLatest(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(productService.getLatestProducts(limit));
    }

    @GetMapping("/discounted")
    public ResponseEntity<List<ProductResponseDto>> getDiscounted(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(productService.getDiscountedProducts(limit));
    }

    @GetMapping("/trending")
    public ResponseEntity<List<ProductResponseDto>> getTrending(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(productService.getTrendingProducts(limit));
    }

    @GetMapping("/category/{categoryId}")
    public ResponseEntity<List<ProductResponseDto>> getProductsByCategory(
            @PathVariable Long categoryId) {
        List<ProductResponseDto> products = productService.getProductsByCategory(categoryId);
        return ResponseEntity.ok(products);
    }


    // 🔹 Category name wise products
//    @GetMapping("/category-name/{categoryName}")
//    public ResponseEntity<List<ProductResponseDto>> getProductsByCategoryName(
//            @PathVariable String categoryName) {
//        List<ProductResponseDto> products = productService.getProductsByCategoryName(categoryName);
//        return ResponseEntity.ok(products);
//    }




    @GetMapping("/search")
    public ResponseEntity<List<ProductResponseDto>> searchProducts(
            @RequestParam String keyword
    ) {
        return ResponseEntity.ok(
                productService.searchProducts(keyword)
        );
    }

    /** Brand অনুযায়ী প্রোডাক্ট fetch */
    @GetMapping("/brand/{brandId}")
    public List<ProductResponseDto> getProductsByBrand(@PathVariable Long brandId) {
        return productService.getProductsByBrandDto(brandId);
    }

    @GetMapping("/vendor/{vendorId}")
    public List<ProductResponseDto> getProductsByVendor(@PathVariable Long vendorId) {
        return productService.getProductsByVendorId(vendorId);
    }

    @GetMapping("/my/product")
    public List<ProductResponseDto> getMyProducts(Authentication authentication) {
        String username = authentication.getName(); // get logged-in username
        Vendor vendor = vendorRepository.findByUserUserName(username)
                .orElseThrow(() -> new RuntimeException("Vendor not found for this user"));
        return productService.getProductsByVendorId(vendor.getId());
    }



}

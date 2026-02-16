package com.abc.SpringSecurityExample.mapper;

import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductResponseDto;
import com.abc.SpringSecurityExample.entity.Product;

public class ProductMapper {

    /** Request DTO -> Entity */
    public static Product toEntity(ProductRequestDto dto) {
        if (dto == null) return null;

        Product product = new Product();
        product.setName(dto.getName());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setDiscountPrice(dto.getDiscountPrice());
        product.setStockQuantity(dto.getStockQuantity());
        product.setStatus(dto.getStatus());
        product.setReleaseDate(dto.getReleaseDate());
        product.setSku(dto.getSku());
        product.setImageUrls(dto.getImageUrls());

        // Backend managed fields
        product.setSoldCount(0); // new product starts with 0 soldCount

        // category, brand, vendor should be set in Service layer
        return product;
    }

    /** Entity -> Response DTO */
    public static ProductResponseDto toDto(Product product) {
        if (product == null) return null;

        ProductResponseDto dto = new ProductResponseDto();
        dto.setId(product.getId());
        dto.setName(product.getName());
        dto.setDescription(product.getDescription());
        dto.setPrice(product.getPrice());
        dto.setDiscountPrice(product.getDiscountPrice());
        dto.setStockQuantity(product.getStockQuantity());
        dto.setStatus(product.getStatus());
        dto.setReleaseDate(product.getReleaseDate());
        dto.setSku(product.getSku());
        dto.setAverageRating(product.getAverageRating());
        dto.setTotalReviews(product.getTotalReviews());
        dto.setImageUrls(product.getImageUrls());
        dto.setSoldCount(product.getSoldCount()); // backend managed

        if (product.getCategory() != null) {
            dto.setCategoryId(product.getCategory().getId());
            dto.setCategoryName(product.getCategory().getName());
        }

        if (product.getBrand() != null) {
            dto.setBrandId(product.getBrand().getId());
            dto.setBrandName(product.getBrand().getName());
        }

        if (product.getVendor() != null) {
            dto.setVendorId(product.getVendor().getId());
            dto.setVendorName(product.getVendor().getShopName());
        }

        dto.setDeleted(product.getDeleted());
        dto.setCreatedAt(product.getCreatedAt());
        dto.setUpdatedAt(product.getUpdatedAt());

        return dto;
    }



}

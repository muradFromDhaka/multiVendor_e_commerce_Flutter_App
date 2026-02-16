package com.abc.SpringSecurityExample.DTOs.projectDtos;

import com.abc.SpringSecurityExample.enums.ProductStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductResponseDto {

    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private BigDecimal discountPrice;
    private Integer stockQuantity;
    private ProductStatus status;
    private LocalDate releaseDate;
    private String sku;
    private Double averageRating;
    private Integer totalReviews;
    private List<String> imageUrls;

    // Flattened relationships
    private Long categoryId;
    private String categoryName;

    private Long brandId;
    private String brandName;

    private Long vendorId;
    private String vendorName;

    // BaseEntity info
    private Boolean deleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Backend managed field
    private Integer soldCount;
}

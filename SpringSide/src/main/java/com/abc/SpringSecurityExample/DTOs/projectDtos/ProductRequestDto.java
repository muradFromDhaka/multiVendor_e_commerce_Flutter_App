package com.abc.SpringSecurityExample.DTOs.projectDtos;

import com.abc.SpringSecurityExample.enums.ProductStatus;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductRequestDto {

    @NotBlank(message = "Product name is required")
    @Size(max = 100, message = "Product name must be less than 100 characters")
    private String name;

    @Size(max = 1000, message = "Description must be less than 1000 characters")
    private String description;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Price must be greater than 0")
    private BigDecimal price;

    @NotNull(message = "Stock quantity is required")
    @Min(value = 0, message = "Stock quantity cannot be negative")
    private Integer stockQuantity;

    @NotBlank(message = "SKU is required")
    private String sku;

    @NotNull(message = "Category is required")
    private Long categoryId;

    @NotNull(message = "brand is required")
    private Long brandId;

    // Optional fields
    private Long vendorId;       // admin can set
    private BigDecimal discountPrice;
    private ProductStatus status;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate releaseDate;
//    private LocalDate releaseDate;

    private List<String> imageUrls; // optional images
}

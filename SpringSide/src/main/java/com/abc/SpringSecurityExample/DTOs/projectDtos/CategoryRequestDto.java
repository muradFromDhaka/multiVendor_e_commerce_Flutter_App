package com.abc.SpringSecurityExample.DTOs.projectDtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CategoryRequestDto {

    @NotBlank(message = "Category name is required")
    @Size(max = 150, message = "Category name must not exceed 150 characters")
    private String name;

    @Size(max = 500, message = "Image URL must not exceed 500 characters")
    private String imageUrl;

    // null → root category
    private Long parentId;
}


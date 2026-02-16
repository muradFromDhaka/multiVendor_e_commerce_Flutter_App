package com.abc.SpringSecurityExample.DTOs.projectDtos;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class CategoryResponseDto {

    private Long id;
    private String name;
    private String imageUrl;

    private Long parentId;
    private String parentName;
    // children categories
    private List<CategoryResponseDto> subCategories;
}


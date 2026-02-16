package com.abc.SpringSecurityExample.DTOs.projectDtos;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BrandResponseDto {

    private Long id;
    private String name;
    private String description;
    private String logoUrl;
}


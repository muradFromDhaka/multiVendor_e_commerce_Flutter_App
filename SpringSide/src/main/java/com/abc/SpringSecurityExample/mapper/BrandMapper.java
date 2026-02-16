package com.abc.SpringSecurityExample.mapper;

import com.abc.SpringSecurityExample.DTOs.projectDtos.BrandRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.BrandResponseDto;
import com.abc.SpringSecurityExample.entity.Brand;

import java.util.List;
import java.util.stream.Collectors;

public class BrandMapper {

    private BrandMapper() {
        // prevent instantiation
    }

    // -------- RequestDto → Entity (Create) --------
    public static Brand toEntity(BrandRequestDto dto) {
        if (dto == null) return null;

        Brand brand = new Brand();
        brand.setName(dto.getName());
        brand.setDescription(dto.getDescription());
        brand.setLogoUrl(dto.getLogoUrl());
        return brand;
    }

    // -------- Entity → ResponseDto --------
    public static BrandResponseDto toResponseDto(Brand brand) {
        if (brand == null) return null;

        BrandResponseDto dto = new BrandResponseDto();
        dto.setId(brand.getId());
        dto.setName(brand.getName());
        dto.setDescription(brand.getDescription());
        dto.setLogoUrl(brand.getLogoUrl());
        return dto;
    }

}


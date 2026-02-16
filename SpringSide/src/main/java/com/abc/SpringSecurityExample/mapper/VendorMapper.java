package com.abc.SpringSecurityExample.mapper;

import com.abc.SpringSecurityExample.DTOs.projectDtos.VendorRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.VendorResponseDto;
import com.abc.SpringSecurityExample.entity.Vendor;

public class VendorMapper {

    private VendorMapper() {} // Prevent instantiation

    // ---------------- Entity → ResponseDto ----------------
    public static VendorResponseDto toDto(Vendor vendor) {
        if (vendor == null) return null;

        VendorResponseDto dto = new VendorResponseDto();

        dto.setId(vendor.getId());
        dto.setShopName(vendor.getShopName());
        dto.setSlug(vendor.getSlug());
        dto.setDescription(vendor.getDescription());
        dto.setStatus(vendor.getStatus());
        dto.setRating(vendor.getRating());
        dto.setUserName(vendor.getUser() != null ? vendor.getUser().getUserName() : null);

        dto.setBusinessEmail(vendor.getBusinessEmail());
        dto.setPhone(vendor.getPhone());
        dto.setAddress(vendor.getAddress());
        dto.setLogoUrl(vendor.getLogoUrl());
        dto.setBannerUrl(vendor.getBannerUrl());

        return dto;
    }

    // ---------------- RequestDto → Entity (Create/Update) ----------------
    public static Vendor toEntity(VendorRequestDto dto, Vendor existingVendor) {
        Vendor vendor = existingVendor != null ? existingVendor : new Vendor();

        vendor.setShopName(dto.getShopName());
        vendor.setDescription(dto.getDescription());
        vendor.setBusinessEmail(dto.getBusinessEmail());
        vendor.setPhone(dto.getPhone());
        vendor.setAddress(dto.getAddress());
        vendor.setLogoUrl(dto.getLogoUrl());
        vendor.setBannerUrl(dto.getBannerUrl());

        return vendor;
    }
}
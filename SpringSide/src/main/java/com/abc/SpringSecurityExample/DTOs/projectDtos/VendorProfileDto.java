package com.abc.SpringSecurityExample.DTOs.projectDtos;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// VendorProfile DTO
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class VendorProfileDto {

    private Long vendorId;
    private String  shopName;
    private String businessEmail;
    private String phone;
    private String address;
    private String logoUrl;
    private String bannerUrl;
}


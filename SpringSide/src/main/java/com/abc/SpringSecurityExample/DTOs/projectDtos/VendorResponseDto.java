package com.abc.SpringSecurityExample.DTOs.projectDtos;

import com.abc.SpringSecurityExample.enums.VendorStatus;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VendorResponseDto {

    private Long id;
    private String shopName;
    private String slug;
    private String description;
    private VendorStatus status;
    private Double rating;
    private String userName;

    private String businessEmail;
    private String phone;
    private String address;
    private String logoUrl;
    private String bannerUrl;
}

package com.abc.SpringSecurityExample.DTOs.projectDtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VendorRequestDto {

    @NotBlank(message = "Shop name is required")
    @Size(max = 255)
    private String shopName;

    @Size(max = 500)
    private String description;

    private String businessEmail;
    private String phone;
    private String address;
    private String logoUrl;
    private String bannerUrl;
}

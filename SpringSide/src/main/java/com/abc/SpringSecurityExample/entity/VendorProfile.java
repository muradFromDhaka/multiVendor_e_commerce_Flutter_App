package com.abc.SpringSecurityExample.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;


@Setter
@Getter
@Table(name = "vendor_profiles")
public class VendorProfile extends BaseEntity {

//    @OneToOne
//    @JoinColumn(name = "vendor_id")
//    private Vendor vendor;
//
//    private String businessEmail;
//    private String phone;
//
//    private String address;
//
//    private String logoUrl;
//    private String bannerUrl;
}


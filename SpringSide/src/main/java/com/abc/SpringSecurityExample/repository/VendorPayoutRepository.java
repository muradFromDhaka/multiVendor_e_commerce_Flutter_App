package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.VendorPayout;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VendorPayoutRepository extends JpaRepository<VendorPayout, Long>{

	Optional<VendorPayout> findByVendorId(Long vendorId);

	Page<VendorPayout> findByVendorId(Long vendorId, PageRequest of);

}

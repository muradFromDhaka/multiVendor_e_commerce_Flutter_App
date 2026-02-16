package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.VendorOrder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VendorOrderRepository extends JpaRepository<VendorOrder, Long>{

	Optional<VendorOrder> findByOrderId(Long orderId);
	Optional<VendorOrder> findByVendorId(Long vendorId);
	Page<VendorOrder> findByVendorId(Long vendorId, PageRequest of);

}

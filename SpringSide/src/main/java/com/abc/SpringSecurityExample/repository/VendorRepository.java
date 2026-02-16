package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.User;
import com.abc.SpringSecurityExample.entity.Vendor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VendorRepository extends JpaRepository<Vendor, Long>{

    // Find vendor by user
    Optional<Vendor> findByUserUserName(String user);

    // Check if vendor exists for a user (used in create)
    boolean existsByUser(User user);

    // Check if slug already exists
    boolean existsBySlug(String slug);

}

package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WishlistRepository extends JpaRepository<Wishlist, Long>{

}

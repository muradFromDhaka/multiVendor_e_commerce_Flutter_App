package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.Cart;
import com.abc.SpringSecurityExample.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CartRepository extends JpaRepository<Cart, Long>{

    Optional<Cart> findByUser(User currentUser);
}

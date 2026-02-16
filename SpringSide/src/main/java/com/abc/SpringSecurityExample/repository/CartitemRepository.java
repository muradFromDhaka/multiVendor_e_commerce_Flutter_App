package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CartitemRepository extends JpaRepository<CartItem, Long>{

}

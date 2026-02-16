package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.Deal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DealRepository extends JpaRepository<Deal, Long>{

}

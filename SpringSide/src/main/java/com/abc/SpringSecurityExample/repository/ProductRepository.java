package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductResponseDto;
import com.abc.SpringSecurityExample.entity.Product;
import com.abc.SpringSecurityExample.enums.ProductStatus;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {

    // ================= BASIC =================
    List<Product> findByDeletedFalse();

    // ================= VENDOR =================
    List<Product> findByVendorId(Long vendorId);

    List<Product> findByVendorIdAndDeletedFalse(Long vendorId);

    // ================= CATEGORY =================
    @Query("""
        SELECT p FROM Product p
        WHERE p.category.id = :categoryId
        AND p.deleted = false
        ORDER BY p.soldCount DESC
    """)
    List<Product> findPopularByCategory(Long categoryId, Pageable pageable);

    // ================= BRAND =================
    @Query("""
        SELECT p FROM Product p
        WHERE p.brand.id = :brandId
        AND p.deleted = false
        ORDER BY p.soldCount DESC
    """)
    List<Product> findPopularByBrand(Long brandId, Pageable pageable);

    // ================= PRICE =================
    List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);

    // ================= DISCOUNT =================
    @Query("""
        SELECT p FROM Product p
        WHERE p.discountPrice IS NOT NULL
        AND p.discountPrice < p.price
        AND p.deleted = false
    """)
    List<Product> findDiscountedProducts(Pageable pageable);

    // ================= LATEST =================
    @Query("""
        SELECT p FROM Product p
        WHERE p.deleted = false
        ORDER BY p.createdAt DESC
    """)
    List<Product> findLatestProducts(Pageable pageable);

    // ================= POPULAR =================
    @Query("""
        SELECT p FROM Product p
        WHERE p.deleted = false
        ORDER BY p.soldCount DESC
    """)
    List<Product> findMostPopularProducts(Pageable pageable);

    // ================= TRENDING =================
    @Query("""
        SELECT p FROM Product p
        WHERE p.deleted = false
        AND p.soldCount > 0
        ORDER BY p.soldCount DESC
    """)
    List<Product> findTrendingProducts(Pageable pageable);


    List<Product> findByCategoryId(Long categoryId);

//    @Query("SELECT p FROM Product p WHERE LOWER(p.category.name) LIKE LOWER(CONCAT('%', :name, '%'))")
//    List<Product> searchByCategoryName(@Param("name") String name);


    @Query("""
        SELECT DISTINCT p
        FROM Product p
        LEFT JOIN p.category c
        LEFT JOIN p.vendor v
        WHERE 
            LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR LOWER(c.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR LOWER(v.shopName) LIKE LOWER(CONCAT('%', :keyword, '%'))
    """)
    List<Product> searchProducts(@Param("keyword") String keyword);


    // Brand ID অনুযায়ী প্রোডাক্ট খুঁজবে
    List<Product> findByBrandId(Long brandId);


}

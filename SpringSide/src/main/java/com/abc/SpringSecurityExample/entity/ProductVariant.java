package com.abc.SpringSecurityExample.entity;



import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;


@Entity
@Table(name = "product_variants")
@Getter @Setter
public class ProductVariant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String variantName; // Color / Size / RAM

    private String variantValue; // Red / XL / 8GB

    private BigDecimal priceAdjustment;

    private Integer stock;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;
}

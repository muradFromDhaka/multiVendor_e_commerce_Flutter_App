package com.abc.SpringSecurityExample.entity;


import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "inventory")
@Getter @Setter
public class Inventory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer availableQuantity;

    private Integer reservedQuantity;

    @OneToOne
    @JoinColumn(name = "product_id")
    private Product product;
}

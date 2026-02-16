package com.abc.SpringSecurityExample.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.Set;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Table(name="Wishlist")
public class Wishlist extends BaseEntity{

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    
    // Wishlist can contain many products
    @ManyToMany
    @JoinTable(
            name = "wishlist_products",
            joinColumns = @JoinColumn(name = "wishlist_id"),
            inverseJoinColumns = @JoinColumn(name = "product_id")
    )
    private Set<Product> products;
    
}

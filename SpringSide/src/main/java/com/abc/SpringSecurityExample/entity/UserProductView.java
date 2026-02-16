package com.abc.SpringSecurityExample.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_product_views")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserProductView {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Many views by one user
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({"orders","reviews","carts","wishlists"})
    private User user;

    // Same product viewed by many users
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    @JsonIgnoreProperties({"category","reviews","cartItem","wishlists","deal"})
    private Product product;

    private LocalDateTime viewedAt;
}

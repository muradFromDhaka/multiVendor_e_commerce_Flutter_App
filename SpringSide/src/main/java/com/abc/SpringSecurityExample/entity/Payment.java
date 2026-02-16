package com.abc.SpringSecurityExample.entity;

import com.abc.SpringSecurityExample.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Data
public class Payment extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;


    private String provider; // Stripe, SSLCommerz, PayPal
    private String transactionId;

    @Enumerated(EnumType.STRING)
    private PaymentStatus status;
}

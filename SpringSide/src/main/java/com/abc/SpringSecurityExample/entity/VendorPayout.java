package com.abc.SpringSecurityExample.entity;

import com.abc.SpringSecurityExample.enums.PayoutStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "vendor_payouts")
public class VendorPayout extends BaseEntity {

    @ManyToOne(optional = false)
    @JoinColumn(name = "vendor_id", nullable = false)
    private Vendor vendor;

    @Column(nullable = false)
    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PayoutStatus status; // PENDING, PAID, FAILED

    private LocalDateTime payoutDate;

    @Column(unique = true, nullable = false)
    private String reference;

    @Column(nullable = false)
    private String method;      // BANK, BKASH, NAGAD, STRIPE

}

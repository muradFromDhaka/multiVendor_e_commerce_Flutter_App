package com.abc.SpringSecurityExample.entity;

import com.abc.SpringSecurityExample.enums.VendorOrderStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Getter
@Setter
@Table(name = "vendor_orders")
public class VendorOrder extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "order_id")
    private Order order;

    @ManyToOne
    @JoinColumn(name = "vendor_id")
    private Vendor vendor;

    private BigDecimal subtotal;

    @Enumerated(EnumType.STRING)
    private VendorOrderStatus status;
}


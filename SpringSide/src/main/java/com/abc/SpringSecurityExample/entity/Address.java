package com.abc.SpringSecurityExample.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Entity
@Data
public class Address extends BaseEntity {

    private String street;
    private String city;
    private String country;
    private String zipCode;

    @ManyToOne
    private User user;
}

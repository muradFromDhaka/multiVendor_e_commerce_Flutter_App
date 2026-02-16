package com.abc.SpringSecurityExample.DTOs.securityDtos;

public record RegisterRequest(
        String username,
        String password,
        String email,
        String firstName,
        String lastName
       
) {}

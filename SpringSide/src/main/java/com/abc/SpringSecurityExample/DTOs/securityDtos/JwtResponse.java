package com.abc.SpringSecurityExample.DTOs.securityDtos;




import com.abc.SpringSecurityExample.entity.User;

public record JwtResponse(
        String jwtToken,
        User user
//        String username,
//        String email,
//        Collection<String> roles
) {}
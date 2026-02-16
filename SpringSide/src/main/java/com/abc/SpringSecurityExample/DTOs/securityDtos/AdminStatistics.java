package com.abc.SpringSecurityExample.DTOs.securityDtos;


import com.abc.SpringSecurityExample.entity.Role;

import java.util.List;

public record AdminStatistics(long totalUsers, long enabledUsers, List<Role> roles) {
}

package com.abc.SpringSecurityExample.DTOs.securityDtos;

import java.util.Set;

public record RoleUpdateRequest(Set<String> roles) {
}

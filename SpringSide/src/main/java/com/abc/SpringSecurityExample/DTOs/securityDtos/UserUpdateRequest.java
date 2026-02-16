package com.abc.SpringSecurityExample.DTOs.securityDtos;

// DTO for update requests
public record UserUpdateRequest(String firstName, String lastName, String email) {
}

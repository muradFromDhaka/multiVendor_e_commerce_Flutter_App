package com.abc.SpringSecurityExample.DTOs.securityDtos;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class RoleDTO {

    @Size(max = 255)
    private String roleName;

    @Size(max = 255)
    private String roleDescription;

}

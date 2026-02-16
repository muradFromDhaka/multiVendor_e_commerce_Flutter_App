package com.abc.SpringSecurityExample.service;



import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.abc.SpringSecurityExample.DTOs.securityDtos.UserDTO;
import com.abc.SpringSecurityExample.Util.NotFoundException;
import com.abc.SpringSecurityExample.entity.Role;
import com.abc.SpringSecurityExample.entity.User;
import com.abc.SpringSecurityExample.repository.RoleRepository;
import com.abc.SpringSecurityExample.repository.UserRepository;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;


@Transactional
@Service
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Autowired
    PasswordEncoder passwordEncoder;

    public UserService(final UserRepository userRepository, final RoleRepository roleRepository) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
    }


    public void initRoleAndUser() {

        Role adminRole = new Role();
        adminRole.setRoleName("ROLE_ADMIN".toString());
        adminRole.setRoleDescription("Admin role");
        adminRole.setDateCreated(OffsetDateTime.now());
        adminRole.setLastUpdated(OffsetDateTime.now());
        roleRepository.save(adminRole);

        Role userRole = new Role();
        userRole.setRoleName("ROLE_USER".toString());
        userRole.setRoleDescription("Default role for newly created record");
        userRole.setDateCreated(OffsetDateTime.now());
        userRole.setLastUpdated(OffsetDateTime.now());
        roleRepository.save(userRole);

        Role vendorRole = new Role();
        vendorRole.setRoleName("ROLE_VENDOR".toString());
        vendorRole.setRoleDescription("Default role for newly created record");
        vendorRole.setDateCreated(OffsetDateTime.now());
        vendorRole.setLastUpdated(OffsetDateTime.now());
        roleRepository.save(vendorRole);

        Role roleMODERATOR = new Role();
        roleMODERATOR.setRoleName("ROLE_MODERATOR");
        roleMODERATOR.setRoleDescription("Default role for newly ROLE_MODERATOR record");
        roleMODERATOR.setDateCreated(OffsetDateTime.now());
        roleMODERATOR.setLastUpdated(OffsetDateTime.now());
        roleRepository.save(roleMODERATOR);


        User adminUser = new User();
        adminUser.setUserName("murad");
        adminUser.setPassword(getEncodedPassword("murad@pass"));
        adminUser.setUserFirstName("murad");
        adminUser.setUserLastName("murad");
        adminUser.setEmail("murad@gmail.com");
        adminUser.setDateCreated(OffsetDateTime.now());
        adminUser.setLastUpdated(OffsetDateTime.now());

        Set<Role> adminRoles = new HashSet<>();
        adminRoles.add(adminRole);
        adminRoles.add(roleMODERATOR);

        adminUser.setRoles(adminRoles);
        userRepository.save(adminUser);

    }


    public List<UserDTO> findAll() {
        final List<User> users = userRepository.findAll(Sort.by("userName"));
        return users.stream()
                .map((user01) -> mapToDTO(user01, new UserDTO()))
                .toList();
    }

    public UserDTO get(final String userName) {
        return userRepository.findById(userName)
                .map(user01 -> mapToDTO(user01, new UserDTO()))
                .orElseThrow(NotFoundException::new);
    }

    public String create(final UserDTO userDTO) {
        final User user = new User();
        mapToEntity(userDTO, user);
        user.setUserName(userDTO.getUserName());
        return userRepository.save(user).getUserName();
    }

    public void update(final String userName, final UserDTO userDTO) {
        final User user = userRepository.findById(userName)
                .orElseThrow(NotFoundException::new);
        mapToEntity(userDTO, user);
        userRepository.save(user);
    }

    public void delete(final String userName) {
        userRepository.deleteById(userName);
    }

    private UserDTO mapToDTO(final User user, final UserDTO userDTO) {
        userDTO.setUserName(user.getUserName());
        userDTO.setUserFirstName(user.getUserFirstName());
        userDTO.setUserLastName(user.getUserLastName());
        userDTO.setPassword(user.getPassword());
        userDTO.setEmail(user.getEmail());
        userDTO.setEnabled(user.getEnabled());
        userDTO.setCredentialsNonExpired(user.getCredentialsNonExpired());
        userDTO.setAccountNonExpired(user.getAccountNonExpired());
        userDTO.setAccountNonLocked(user.getAccountNonLocked());
        userDTO.setRoles(user.getRoles() == null ? null : user.getRoles().stream()
                .map(role01 -> role01.getRoleName())
                .toList());
        return userDTO;
    }

    private User mapToEntity(final UserDTO userDTO, final User user) {
        user.setUserFirstName(userDTO.getUserFirstName());
        user.setUserLastName(userDTO.getUserLastName());
        user.setPassword(userDTO.getPassword());
        user.setEmail(userDTO.getEmail());
        user.setEnabled(userDTO.getEnabled());
        user.setCredentialsNonExpired(userDTO.getCredentialsNonExpired());
        user.setAccountNonExpired(userDTO.getAccountNonExpired());
        user.setAccountNonLocked(userDTO.getAccountNonLocked());
        final List<Role> roles = roleRepository.findAllById(
                userDTO.getRoles() == null ? Collections.emptyList() : userDTO.getRoles());
        if (roles.size() != (userDTO.getRoles() == null ? 0 : userDTO.getRoles().size())) {
            throw new NotFoundException("one of roles not found");
        }
        user.setRoles(roles.stream().collect(Collectors.toSet()));
        return user;
    }

    public boolean userNameExists(final String userName) {
        return userRepository.existsByUserNameIgnoreCase(userName);
    }

    public boolean emailExists(final String email) {
        return userRepository.existsByEmailIgnoreCase(email);
    }

    public String getEncodedPassword(String password) {
        return passwordEncoder.encode(password);
    }


    public Page<UserDTO> getAllUsers(int page, int size, String sortBy, String sortDir) {
        Sort sort = Sort.by(Sort.Order.asc(sortBy)); // Default is ascending order
        if ("desc".equalsIgnoreCase(sortDir)) {
            sort = Sort.by(Sort.Order.desc(sortBy));
        }

        Pageable pageable = PageRequest.of(page, size, sort);

        Page<UserDTO> userDTOPage = userRepository.findAll(pageable).map(user -> mapToDTO(user, new UserDTO()));
        return userDTOPage;
    }


    public Page<UserDTO> searchUsers(String searchTerm, int page, int size, String sortBy, String sortDir) {
        Sort sort = Sort.by(Sort.Order.asc(sortBy)); // Default to ascending order
        if ("desc".equalsIgnoreCase(sortDir)) {
            sort = Sort.by(Sort.Order.desc(sortBy));
        }
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<User> userPage = userRepository.findByUserNameContainingIgnoreCaseOrUserFirstNameContainingIgnoreCaseOrUserLastNameContainingIgnoreCaseOrEmailContainingIgnoreCase(
                searchTerm, searchTerm, searchTerm, searchTerm, pageable);

        return userPage.map(user -> mapToDTO(user, new UserDTO()));
    }


    public static class TestFileStorageService {

        @Value("${file.upload-dir}")
        private  String uploadDir;

        private Path uploadPath;

        @PostConstruct
        public void init() throws IOException {
            uploadPath = Paths.get(uploadDir);
            if(!Files.exists(uploadPath)){
                Files.createDirectories(uploadPath);
            }
        }

        public String saveFile(MultipartFile file) throws IOException{
            if(file == null && file.isEmpty()){
                throw new IllegalArgumentException("File is empty.");
            }

            String fileName = UUID.randomUUID()+ "-" + file.getOriginalFilename();
            Path targetPath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(),targetPath, StandardCopyOption.REPLACE_EXISTING);

            return targetPath.toString();

        }

        public void deleteFile(String fileName) throws IOException{
            Files.deleteIfExists(uploadPath.resolve(fileName));
        }

    }
}

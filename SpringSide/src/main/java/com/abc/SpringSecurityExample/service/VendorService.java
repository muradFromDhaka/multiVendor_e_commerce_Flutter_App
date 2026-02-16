package com.abc.SpringSecurityExample.service;

import com.abc.SpringSecurityExample.DTOs.projectDtos.*;
import com.abc.SpringSecurityExample.entity.OrderItem;
import com.abc.SpringSecurityExample.entity.Vendor;
import com.abc.SpringSecurityExample.entity.User;
import com.abc.SpringSecurityExample.mapper.OrderMapper;
import com.abc.SpringSecurityExample.mapper.VendorMapper;
import com.abc.SpringSecurityExample.repository.OrderItemRepository;
import com.abc.SpringSecurityExample.repository.UserRepository;
import com.abc.SpringSecurityExample.repository.VendorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class  VendorService {

    private final VendorRepository vendorRepository;
    private final UserRepository userRepository;
    private final OrderItemRepository orderItemRepository;

    // ---------------- CREATE ----------------
    public VendorResponseDto createVendor(VendorRequestDto dto) {
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        System.out.println("Logged in username:------------------------- " + userName);
        User user = userRepository.findById(userName)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (vendorRepository.existsByUser(user)) {
            throw new RuntimeException("This user already has a vendor");
        }

        Vendor vendor = VendorMapper.toEntity(dto, null);
        vendor.setUser(user);

        // TODO: Implement your SlugUtil
        String baseSlug = SlugUtil.toSlug(dto.getShopName());
        String slug = baseSlug;
        int count = 1;
        while (vendorRepository.existsBySlug(slug)) {
            slug = baseSlug + "-" + count++;
        }
        vendor.setSlug(slug);

        Vendor savedVendor = vendorRepository.save(vendor);
        return VendorMapper.toDto(savedVendor);
    }

    // ---------------- GET ALL ----------------
    public List<VendorResponseDto> getAllVendors() {
        return vendorRepository.findAll()
                .stream()
                .map(VendorMapper::toDto)
                .collect(Collectors.toList());
    }

    // ---------------- GET BY ID ----------------
    public VendorResponseDto getVendorById(Long id) {
        Vendor vendor = vendorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vendor not found with id: " + id));

        return VendorMapper.toDto(vendor);
    }

    // ---------------- UPDATE ----------------
    public VendorResponseDto updateVendor(Long id, VendorRequestDto dto) {
        Vendor existing = vendorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vendor not found with id: " + id));

        Vendor updated = VendorMapper.toEntity(dto, existing);
        Vendor savedVendor = vendorRepository.save(updated);

        return VendorMapper.toDto(savedVendor);
    }

    // ---------------- DELETE ----------------
    public void deleteVendor(Long id) {
        Vendor vendor = vendorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vendor not found with id: " + id));

        vendorRepository.delete(vendor);
    }

    // ---------------- GET VENDOR BY LOGGED-IN USER ----------------
    public VendorResponseDto getMyVendor() {
        Vendor vendor = getLoggedInVendor();
        return VendorMapper.toDto(vendor);
    }

    // ---------------- GET LOGGED-IN VENDOR ----------------
    public Vendor getLoggedInVendor() {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        return vendorRepository.findByUserUserName(username)
                .orElseThrow(() -> new RuntimeException("Vendor not found"));
    }

    // ---------------- GET ALL ORDER ITEMS OF LOGGED-IN VENDOR ----------------
    public List<OrderItemResponseDTO> getMyOrderItems() {
        Vendor vendor = getLoggedInVendor();
        return orderItemRepository.findByVendor(vendor)
                .stream()
                .map(OrderMapper::mapOrderItemToDto)
                .collect(Collectors.toList());
    }


    // ---------------- GET ALL ORDERS OF LOGGED-IN VENDOR ----------------
    public List<OrderResponseDto> getMyOrders() {
        Vendor vendor = getLoggedInVendor();
        return orderItemRepository.findOrdersByVendorId(vendor.getId())
                .stream()
                .map(OrderMapper::toOrderResponseDto) // Order → OrderResponseDto
                .collect(Collectors.toList());
    }

}

package com.abc.SpringSecurityExample.Controller;

import com.abc.SpringSecurityExample.DTOs.projectDtos.BrandRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.BrandResponseDto;
import com.abc.SpringSecurityExample.service.BrandService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/brands")
@RequiredArgsConstructor
public class BrandController {

    private final BrandService brandService;

    // ---------------- CREATE BRAND ----------------
    @PostMapping
    public ResponseEntity<BrandResponseDto> createBrand(
            @RequestPart("brand") BrandRequestDto dto,
            @RequestPart(value = "logo", required = false) MultipartFile logo
    ) throws IOException {
        BrandResponseDto created = brandService.create(dto, logo);
        return ResponseEntity.ok(created);
    }

    // ---------------- UPDATE BRAND ----------------
    @PutMapping("/{id}")
    public ResponseEntity<BrandResponseDto> updateBrand(
            @PathVariable Long id,
            @RequestPart("brand") BrandRequestDto dto,
            @RequestPart(value = "logo", required = false) MultipartFile logo
    ) throws IOException {
        BrandResponseDto updated = brandService.update(id, dto, logo);
        return ResponseEntity.ok(updated);
    }

    // ---------------- DELETE BRAND ----------------
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBrand(@PathVariable Long id) throws IOException {
        brandService.delete(id);
        return ResponseEntity.noContent().build();
    }

    // ---------------- GET BRAND BY ID ----------------
    @GetMapping("/{id}")
    public ResponseEntity<BrandResponseDto> getBrandById(@PathVariable Long id) {
        return ResponseEntity.ok(brandService.getById(id));
    }

    // ---------------- GET ALL BRANDS ----------------
    @GetMapping
    public ResponseEntity<List<BrandResponseDto>> getAllBrands() {
        return ResponseEntity.ok(brandService.getAll());
    }
}

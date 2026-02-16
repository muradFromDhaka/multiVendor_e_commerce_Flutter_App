package com.abc.SpringSecurityExample.Controller;

import com.abc.SpringSecurityExample.DTOs.projectDtos.CategoryRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.CategoryResponseDto;
import com.abc.SpringSecurityExample.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public List<CategoryResponseDto> getAllCategories() {
        return categoryService.getAllCategories();
    }


    // ---------------- CREATE CATEGORY ----------------
    @PostMapping
    public ResponseEntity<CategoryResponseDto> createCategory(
            @RequestPart("category") CategoryRequestDto dto,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) throws IOException {
        CategoryResponseDto created = categoryService.createCategory(dto, image);
        return ResponseEntity.ok(created);
    }

    // ---------------- UPDATE CATEGORY ----------------
    @PutMapping("/{id}")
    public ResponseEntity<CategoryResponseDto> updateCategory(
            @PathVariable Long id,
            @RequestPart("category") CategoryRequestDto dto,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) throws IOException {
        CategoryResponseDto updated = categoryService.updateCategory(id, dto, image);
        return ResponseEntity.ok(updated);
    }

    // ---------------- DELETE CATEGORY ----------------
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id) throws IOException {
        categoryService.deleteCategory(id);
        return ResponseEntity.noContent().build();
    }

    // ---------------- GET CATEGORY BY ID ----------------
    @GetMapping("/{id}")
    public ResponseEntity<CategoryResponseDto> getCategoryById(@PathVariable Long id) {
        return ResponseEntity.ok(categoryService.getCategoryById(id));
    }

    // ---------------- GET ALL ROOT CATEGORIES ----------------
    @GetMapping("/root")
    public ResponseEntity<List<CategoryResponseDto>> getAllRootCategories() {
        return ResponseEntity.ok(categoryService.getAllRootCategories());
    }

    // ---------------- GET SUBCATEGORIES ----------------
    @GetMapping("/{id}/subcategories")
    public ResponseEntity<List<CategoryResponseDto>> getSubCategories(@PathVariable Long id) {
        return ResponseEntity.ok(categoryService.getSubCategories(id));
    }
}

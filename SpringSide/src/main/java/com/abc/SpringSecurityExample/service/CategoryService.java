package com.abc.SpringSecurityExample.service;

import com.abc.SpringSecurityExample.DTOs.projectDtos.CategoryRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.CategoryResponseDto;
import com.abc.SpringSecurityExample.entity.Category;
import com.abc.SpringSecurityExample.mapper.CategoryMapper;
import com.abc.SpringSecurityExample.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final FileStorageService fileStorageService;

    // ---------------- CREATE CATEGORY ----------------
    @Transactional
    public CategoryResponseDto createCategory(CategoryRequestDto dto, MultipartFile image) throws IOException {

        Category parent = null;
        if (dto.getParentId() != null) {
            parent = categoryRepository.findById(dto.getParentId())
                    .orElseThrow(() -> new RuntimeException("Parent category not found"));
        }

        Category category = CategoryMapper.toEntity(dto, parent);

        // Handle image upload
        if (image != null && !image.isEmpty()) {
            String fileName = fileStorageService.saveFile(image);
            category.setImageUrl(fileName);
        }

        Category saved = categoryRepository.save(category);
        return CategoryMapper.toResponseDto(saved);
    }

    // ---------------- UPDATE CATEGORY ----------------
    @Transactional
    public CategoryResponseDto updateCategory(Long id, CategoryRequestDto dto, MultipartFile image) throws IOException {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        category.setName(dto.getName());
        category.setParent(
                dto.getParentId() != null
                        ? categoryRepository.findById(dto.getParentId())
                        .orElseThrow(() -> new RuntimeException("Parent category not found"))
                        : null
        );

        // Handle image update
        if (image != null && !image.isEmpty()) {
            if (category.getImageUrl() != null) {
                fileStorageService.deleteFile(category.getImageUrl());
            }
            String fileName = fileStorageService.saveFile(image);
            category.setImageUrl(fileName);
        }

        Category updated = categoryRepository.save(category);
        return CategoryMapper.toResponseDto(updated);
    }

    // ---------------- DELETE CATEGORY ----------------
    @Transactional
    public void deleteCategory(Long id) throws IOException {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));

        // Delete image if exists
        if (category.getImageUrl() != null) {
            fileStorageService.deleteFile(category.getImageUrl());
        }

        categoryRepository.delete(category);
    }

    // ---------------- GET CATEGORY BY ID ----------------
    @Transactional(readOnly = true)
    public CategoryResponseDto getCategoryById(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        return CategoryMapper.toResponseDto(category);
    }

    // ---------------- GET ALL ROOT CATEGORIES ----------------
    @Transactional(readOnly = true)
    public List<CategoryResponseDto> getAllRootCategories() {
        List<Category> rootCategories = categoryRepository.findByParentIsNull();
        return CategoryMapper.toResponseDtoList(rootCategories);
    }

    // ---------------- GET SUBCATEGORIES OF A CATEGORY ----------------
    @Transactional(readOnly = true)
    public List<CategoryResponseDto> getSubCategories(Long parentId) {
        Category parent = categoryRepository.findById(parentId)
                .orElseThrow(() -> new RuntimeException("Parent category not found"));
        List<Category> subCategories = parent.getSubCategories();
        return CategoryMapper.toResponseDtoList(subCategories);
    }

    @Transactional(readOnly = true)
    public List<CategoryResponseDto> getAllCategories() {
        return categoryRepository.findAll()
                .stream()
                .map(CategoryMapper::toResponseDto)
                .toList();
    }

}

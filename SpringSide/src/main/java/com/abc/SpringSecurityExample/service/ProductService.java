package com.abc.SpringSecurityExample.service;

import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductRequestDto;
import com.abc.SpringSecurityExample.DTOs.projectDtos.ProductResponseDto;
import com.abc.SpringSecurityExample.entity.Brand;
import com.abc.SpringSecurityExample.entity.Category;
import com.abc.SpringSecurityExample.entity.Product;
import com.abc.SpringSecurityExample.entity.Vendor;
import com.abc.SpringSecurityExample.mapper.ProductMapper;
import com.abc.SpringSecurityExample.repository.BrandRepository;
import com.abc.SpringSecurityExample.repository.CategoryRepository;
import com.abc.SpringSecurityExample.repository.ProductRepository;
import com.abc.SpringSecurityExample.repository.VendorRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final VendorRepository vendorRepository;
    private final FileStorageService fileStorageService;


    public ProductResponseDto createProduct(ProductRequestDto dto, MultipartFile[] images) throws IOException {
        Product product = ProductMapper.toEntity(dto);

        // Set relations: Category & Brand
        Category category = categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));
        Brand brand = brandRepository.findById(dto.getBrandId())
                .orElseThrow(() -> new RuntimeException("Brand not found"));
        product.setCategory(category);
        product.setBrand(brand);

        // ---------------- Role-based Vendor Assignment ----------------
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName(); // Logged-in username
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (isAdmin) {
            // Admin can manually assign vendor
            if (dto.getVendorId() != null) {
                Vendor vendor = vendorRepository.findById(dto.getVendorId())
                        .orElseThrow(() -> new RuntimeException("Vendor not found"));
                product.setVendor(vendor);
            }
        } else {
            // Normal Vendor: automatically assign current vendor
            Vendor currentVendor = vendorRepository.findByUserUserName(username)
                    .orElseThrow(() -> new RuntimeException("Vendor not found for current user"));
            product.setVendor(currentVendor);
        }

        // ---------------- Handle Images ----------------
        if (images != null && images.length > 0) {
            List<String> imageUrls = List.of(images).stream()
                    .map(file -> {
                        try {
                            return fileStorageService.saveFile(file);
                        } catch (IOException e) {
                            throw new RuntimeException("Image upload failed: " + file.getOriginalFilename());
                        }
                    }).collect(Collectors.toList());
            product.setImageUrls(imageUrls);
        }

        // Save product
        Product saved = productRepository.save(product);
        return ProductMapper.toDto(saved);
    }

    public ProductResponseDto updateProduct(Long id, ProductRequestDto dto, MultipartFile[] images) throws IOException {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // ---------------- Role-based Access Check ----------------
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (!isAdmin) {
            // Vendor can only update their own products
            Vendor currentVendor = vendorRepository.findByUserUserName(username)
                    .orElseThrow(() -> new RuntimeException("Vendor not found for current user"));

            if (!currentVendor.getId().equals(product.getVendor().getId())) {
                throw new RuntimeException("You are not authorized to update this product");
            }
        }

        // ---------------- Map basic fields ----------------
        product.setName(dto.getName());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setDiscountPrice(dto.getDiscountPrice());
        product.setStockQuantity(dto.getStockQuantity());
        product.setStatus(dto.getStatus());
        product.setReleaseDate(dto.getReleaseDate());
        product.setSku(dto.getSku());

        // ---------------- Update Relations ----------------
        Category category = categoryRepository.findById(dto.getCategoryId())
                .orElseThrow(() -> new RuntimeException("Category not found"));
        Brand brand = brandRepository.findById(dto.getBrandId())
                .orElseThrow(() -> new RuntimeException("Brand not found"));
        product.setCategory(category);
        product.setBrand(brand);

        if (isAdmin) {
            // Admin can change vendor
            if (dto.getVendorId() != null) {
                Vendor vendor = vendorRepository.findById(dto.getVendorId())
                        .orElseThrow(() -> new RuntimeException("Vendor not found"));
                product.setVendor(vendor);
            }
        }

        // ---------------- Update Images ----------------
        List<String> finalImages = new ArrayList<>();

// 1️⃣ keep existing images from DTO
        if (dto.getImageUrls() != null) {
            finalImages.addAll(dto.getImageUrls());
        }

// 2️⃣ add newly uploaded images
        if (images != null && images.length > 0) {
            for (MultipartFile file : images) {
                String savedImage = fileStorageService.saveFile(file);
                finalImages.add(savedImage);
            }
        }

// 3️⃣ set merged image list
        product.setImageUrls(finalImages);


        // Save updated product
        Product updated = productRepository.save(product);
        return ProductMapper.toDto(updated);
    }



    /** GET PRODUCT BY ID */
    public ProductResponseDto getProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        return ProductMapper.toDto(product);
    }


    public void deleteProduct(Long id) throws IOException {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // ---------------- Role-based Access ----------------
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));

        if (!isAdmin) {
            // Vendor can only delete their own products
            Vendor currentVendor = vendorRepository.findByUserUserName(username)
                    .orElseThrow(() -> new RuntimeException("Vendor not found for current user"));

            if (!currentVendor.getId().equals(product.getVendor().getId())) {
                throw new RuntimeException("You are not authorized to delete this product");
            }
        }

        // ---------------- Delete Images ----------------
        if (product.getImageUrls() != null && !product.getImageUrls().isEmpty()) {
            for (String path : product.getImageUrls()) {
                try {
                    fileStorageService.deleteFile(path);
                } catch (IOException e) {
                    System.out.println("Failed to delete image: {}" +e.getMessage());
                }
            }
        }

        // ---------------- Soft Delete ----------------
        product.setDeleted(true);
        productRepository.save(product);

        System.out.println("Product deleted (soft) with images removed: {}" +product.getId());
    }





    /** LIST ALL PRODUCTS */
    public List<ProductResponseDto> listAllProducts() {
        return productRepository.findByDeletedFalse()
                .stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }

    /** LIST MOST POPULAR PRODUCTS */
    public List<ProductResponseDto> getMostPopularProducts(int limit) {
        return productRepository.findMostPopularProducts(PageRequest.of(0, limit))
                .stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }

    /** LIST LATEST PRODUCTS */
    public List<ProductResponseDto> getLatestProducts(int limit) {
        return productRepository.findLatestProducts(PageRequest.of(0, limit))
                .stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }

    /** LIST DISCOUNTED PRODUCTS */
    public List<ProductResponseDto> getDiscountedProducts(int limit) {
        return productRepository.findDiscountedProducts(PageRequest.of(0, limit))
                .stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }

    /** LIST TRENDING PRODUCTS */
    public List<ProductResponseDto> getTrendingProducts(int limit) {
        return productRepository.findTrendingProducts(PageRequest.of(0, limit))
                .stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }


    public List<ProductResponseDto> getProductsByCategory(Long categoryId) {
        List<Product> products = productRepository.findByCategoryId(categoryId);

        // Mapping: Product → ProductResponseDto
        return products.stream().map(p -> {
            ProductResponseDto dto = new ProductResponseDto();
            dto.setId(p.getId());
            dto.setName(p.getName());
            dto.setPrice(p.getPrice());
            dto.setDiscountPrice(p.getDiscountPrice());
            dto.setAverageRating(p.getAverageRating());
            dto.setImageUrls(p.getImageUrls());
            return dto;
        }).toList();
    }


    public List<ProductResponseDto> searchProducts(String keyword) {

        List<Product> products = productRepository.searchProducts(keyword);

        return products.stream()
                .map(ProductMapper::toDto)
                .toList();
    }



    public List<ProductResponseDto> getProductsByBrandDto(Long brandId) {
        List<Product> products = productRepository.findByBrandId(brandId);

        // Map Product -> ProductResponseDto
        return products.stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }


    public List<ProductResponseDto> getProductsByVendorId(Long vendorID) {
        List<Product> products = productRepository.findByVendorId(vendorID);

        // Map Product -> ProductResponseDto
        return products.stream()
                .map(ProductMapper::toDto)
                .collect(Collectors.toList());
    }




}

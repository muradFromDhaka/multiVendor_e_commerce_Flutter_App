package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.OrderItem;
import com.abc.SpringSecurityExample.entity.Vendor;
import com.abc.SpringSecurityExample.entity.Product;
import com.abc.SpringSecurityExample.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    // 1️⃣ All items for a vendor
    List<OrderItem> findByVendor(Vendor vendor);

    // 2️⃣ All items for a product
    List<OrderItem> findByProduct(Product product);

    // 3️⃣ All items for a specific order
    List<OrderItem> findByOrderId(Long orderId);

    // 4️⃣ Count total quantity sold per product
    Long countByProduct(Product product);

    // 5️⃣ All items of a vendor in a specific order
    List<OrderItem> findByVendorIdAndOrderId(Long vendorId, Long orderId);

    // 6️⃣ Total revenue for a vendor
    default Double totalRevenueByVendor(Vendor vendor) {
        return findByVendor(vendor).stream()
                .mapToDouble(item -> item.getUnitPrice().doubleValue() * item.getQuantity())
                .sum();
    }

    // 7️⃣ Vendor-specific orders (distinct)
    @Query("SELECT DISTINCT oi.order FROM OrderItem oi WHERE oi.vendor.id = :vendorId")
    List<Order> findOrdersByVendorId(@Param("vendorId") Long vendorId);
}

package com.abc.SpringSecurityExample.repository;

import com.abc.SpringSecurityExample.entity.Order;
import com.abc.SpringSecurityExample.entity.User;
import com.abc.SpringSecurityExample.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    // 1️⃣ All orders by user
    List<Order> findByUser(User user);

    // 2️⃣ Orders by status
    List<Order> findByOrderStatus(OrderStatus status);

    // 3️⃣ Orders by user + status
    List<Order> findByUserAndOrderStatus(User user, OrderStatus status);

    // 4️⃣ Orders by multiple statuses
    List<Order> findByOrderStatusIn(List<OrderStatus> statuses);

    // 5️⃣ Orders containing a specific product
    List<Order> findByOrderItems_ProductId(Long productId);

    // 6️⃣ Latest N orders for user
//    List<Order> findTop10ByUserOrderByDateCreatedDesc(User user);

    // 7️⃣ Vendor-specific orders (distinct)
    @Query("SELECT DISTINCT o FROM Order o JOIN o.orderItems oi WHERE oi.vendor.id = :vendorId")
    List<Order> findOrdersByVendorId(@Param("vendorId") Long vendorId);
}

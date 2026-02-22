// lib/ui/public/cart/cart_item_widget.dart
import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/models/cart/cart_item_response.dart';
import 'package:multivendor_flutter_app/services/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multivendor_flutter_app/ui/user/user_cart/price_formatter.dart';

class CartItemWidget extends StatefulWidget {
  final CartItemResponse item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int _quantity;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
  }

  @override
  void didUpdateWidget(CartItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      setState(() {
        _quantity = widget.item.quantity;
      });
    }
  }

  Future<void> _updateQuantity(int newQuantity) async {
    if (newQuantity < 1 || newQuantity > 10 || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    await widget.onQuantityChanged(newQuantity);

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 120,
              color: Colors.grey[200],
              child: widget.item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: "${ApiConfig.imgBaseUrl}/${widget.item.imageUrl}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.image, color: Colors.grey, size: 40),
            ),
          ),
          
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Price
                  Text(
                    PriceFormatter.format(widget.item.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Quantity and Total
                  Row(
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: _isUpdating 
                                  ? null 
                                  : () => _updateQuantity(_quantity - 1),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: _isUpdating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      '$_quantity',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: _isUpdating 
                                  ? null 
                                  : () => _updateQuantity(_quantity + 1),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Item Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            PriceFormatter.format(widget.item.total),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Remove Button
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _isUpdating ? null : widget.onRemove,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
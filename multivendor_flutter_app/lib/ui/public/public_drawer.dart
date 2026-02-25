import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/auth_service.dart';
import 'package:multivendor_flutter_app/services/cart_service.dart';
import 'package:multivendor_flutter_app/ui/auth/login_page.dart';
import 'package:multivendor_flutter_app/ui/auth/register_page.dart';

class PublicAppMenuDrawer extends StatefulWidget {
  const PublicAppMenuDrawer({super.key});

  @override
  State<PublicAppMenuDrawer> createState() => _PublicAppMenuDrawerState();
}

class _PublicAppMenuDrawerState extends State<PublicAppMenuDrawer> {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _userName;
  String? _profileImage;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Check login
    final loggedIn = await _authService.isLoggedIn();
    _isLoggedIn = loggedIn;

    if (loggedIn) {
      // Current user info from JWT
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _userName =
            "${user['userFirstName'] ?? ''} ${user['userLastName'] ?? ''}"
                .trim();
        // Profile image example, যদি backend-এ থাকে
        _profileImage = user['profileImageUrl']; // or null for placeholder
      }

      // Cart count (তুমি backend থেকে fetch করতে পারো)
      _cartCount = await _getCartCount();
    } else {
      _userName = null;
      _profileImage = null;
      _cartCount = 0;
    }

    if (mounted) setState(() {});
  }

  Future<int> _getCartCount() async {
    try {
      final cartService = CartService();
      final cartDto = await cartService.loadCart();

      // Assuming cartDto.items is a list of cart items
      if (cartDto.items != null) {
        return cartDto.items!.length;
      }
      return 0;
    } catch (e) {
      print("Error loading cart count: $e");
      return 0; // default if failed
    }
  }

  Future<void> _handleLoginLogout(BuildContext context) async {
    Navigator.pop(context);

    if (_isLoggedIn) {
      await _authService.logout();
      setState(() {
        _isLoggedIn = false;
        _userName = null;
        _profileImage = null;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      ).then((_) => _loadData());
    }
  }

  Widget _buildCartBadge() {
    return Stack(
      children: [
        const Icon(Icons.shopping_cart_outlined),
        if (_cartCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _cartCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ✅ HEADER WITH USER INFO
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  /// ✅ Profile Image
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: _profileImage != null
                        ? NetworkImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  /// ✅ Username
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoggedIn ? (_userName ?? "User") : "Welcome Guest",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoggedIn
                              ? "Glad to see you back"
                              : "Please login to continue",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ CART WITH BADGE
            ListTile(
              leading: _buildCartBadge(),
              title: const Text("My Cart"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Cart Page
              },
            ),

            const Divider(),

            /// ✅ CREATE ACCOUNT (only অতিথি হলে)
            if (!_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.person_add_alt_1),
                title: const Text("Create Account"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegistrationPage()),
                  );
                },
              ),

            if (!_isLoggedIn) const Divider(height: 0),

            /// ✅ LOGIN / LOGOUT
            ListTile(
              leading: Icon(_isLoggedIn ? Icons.logout : Icons.login),
              title: Text(_isLoggedIn ? "Logout" : "Login"),
              onTap: () => _handleLoginLogout(context),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Multivendor App v1.0",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

//=======================CommonVendorAppBar===========================
class CommonAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CommonAdminAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

//========================CommonVendorDrawer===============================

class CommonAdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final String? userName;
  final String? userEmail;

  const CommonAdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
    required this.isDarkMode,
    this.userName,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.branding_watermark, 'title': 'VendorHome'},
      {'icon': Icons.people_outline, 'title': 'Brand'},
      {'icon': Icons.receipt_long_outlined, 'title': 'Category'},
      {'icon': Icons.settings_outlined, 'title': 'Proudcts'},
      {'icon': Icons.branding_watermark, 'title': 'Orders'},
      {'icon': Icons.dashboard_outlined, 'title': 'Payout'},
      {'icon': Icons.inventory_2_outlined, 'title': 'Earnings'},
      {'icon': Icons.settings_outlined, 'title': 'Repors'},
      {'icon': Icons.settings_outlined, 'title': 'Vendor create'},
      {'icon': Icons.dashboard_outlined, 'title': 'Vendors Profile'},
    ];

    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(isDarkMode ? 0.25 : 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? Colors.blue
                            : (isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700]),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.blue
                              : (isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[800]),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        onItemSelected(index);
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: onLogout,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.indigo]),
      ),
      accountName: Text(userName ?? 'Admin User'),
      accountEmail: Text(userEmail ?? ''),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.admin_panel_settings, color: Colors.blue),
      ),
    );
  }
}

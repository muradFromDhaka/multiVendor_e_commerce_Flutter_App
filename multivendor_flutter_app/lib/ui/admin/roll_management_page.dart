import 'package:flutter/material.dart';
import 'package:multivendor_flutter_app/services/admin_service.dart';

class RoleManagementPage extends StatefulWidget {
  const RoleManagementPage({super.key});

  @override
  State<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends State<RoleManagementPage> {
  final AdminService _adminService = AdminService();

  List<dynamic> _roles = [];
  List<dynamic> _usersByRole = [];

  bool _isRolesLoading = true;
  bool _isUsersLoading = false;

  String? _selectedRoleName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  /* ================= LOAD ROLES ================= */
  Future<void> _loadRoles() async {
    setState(() {
      _isRolesLoading = true;
      _error = null;
    });

    try {
      final roles = await _adminService.getAllRoles();
      print("Roles fetched:---------------${roles.length} & $roles");

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _isRolesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRolesLoading = false;
        _error = "Failed to load roles";
      });
    }
  }

  /* ================= LOAD USERS BY ROLE ================= */
  Future<void> _loadUsersByRole(String roleName) async {
    print("Fetching users for role: $roleName");

    setState(() {
      _selectedRoleName = roleName;
      _isUsersLoading = true;
      _usersByRole = [];
    });

    try {
      final users = await _adminService.getUsersByRole(roleName);
      print("Users fetched: $users");

      if (!mounted) return;

      setState(() {
        _usersByRole = users;
        _isUsersLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");

      if (!mounted) return;

      setState(() {
        _isUsersLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load users")));
    }
  }

  /* ================= CREATE ROLE ================= */
  Future<void> _showCreateRoleDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              setStateDialog(() => isSubmitting = true);

              try {
                await _adminService.createRole(nameController.text.trim());

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Role created")));

                _loadRoles();
              } catch (_) {
                setStateDialog(() => isSubmitting = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Role already exists")),
                );
              }
            }

            return AlertDialog(
              title: const Text("Create Role"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Role Name"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /* ================= ASSIGN ROLES ================= */
  Future<void> _showAssignRolesDialog(dynamic user) async {
    final controller = TextEditingController(
      text: (user['roles'] ?? []).map((r) => r['roleName']).join(', '),
    );

    await showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> submit() async {
              final rolesArray = controller.text
                  .split(',')
                  .map((r) => r.trim())
                  .where((r) => r.isNotEmpty)
                  .toList();

              setStateDialog(() => isSubmitting = true);

              try {
                await _adminService.updateUserRoles(
                  user['userName'],
                  rolesArray,
                );

                if (!mounted) return;

                Navigator.pop(context);
                if (_selectedRoleName != null) {
                  _loadUsersByRole(_selectedRoleName!);
                }
              } catch (_) {
                setStateDialog(() => isSubmitting = false);
              }
            }

            return AlertDialog(
              title: Text("Assign Roles → ${user['userName']}"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "ROLE_ADMIN, ROLE_USER",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /* ================= ROLE PANEL ================= */
  Widget _buildRolesPanel() {
    if (_isRolesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Column(
      children: [
        Row(
          children: [
            const Text(
              "Role List",
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            const Spacer(),
            IconButton(
              onPressed: _showCreateRoleDialog,
              icon: Row(
                children: [
                  Icon(Icons.add),
                  Text(
                    "Add Role",
                    style: TextStyle(fontSize: 17, color: Colors.purpleAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: _roles.isEmpty
              ? const Center(child: Text("No roles found"))
              : Container(
                  color: const Color.fromARGB(255, 219, 236, 220),
                  child: ListView.builder(
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      final roleName = role['roleName'] ?? "Unnamed Role";

                      return Card(
                        color: const Color.fromARGB(255, 223, 208, 208),
                        child: ListTile(
                          title: Text(roleName),
                          trailing: TextButton(
                            onPressed: () => _loadUsersByRole(roleName),
                            child: const Text("View Users"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  /* ================= USERS PANEL ================= */
  Widget _buildUsersPanel() {
    if (_selectedRoleName == null) {
      return const Center(child: Text("Select a role"));
    }

    if (_isUsersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_usersByRole.isEmpty) {
      return const Center(child: Text("No users for this role"));
    }

    return Container(
      color: const Color.fromARGB(255, 202, 197, 197),
      child: ListView.builder(
        itemCount: _usersByRole.length,
        itemBuilder: (context, index) {
          final user = _usersByRole[index];
          return Card(
            color: Colors.white,
            child: ListTile(
              title: Text(user['userName'] ?? "Unknown User"),
              subtitle: Text(user['email'] ?? ''),
              trailing: ElevatedButton(
                onPressed: () => _showAssignRolesDialog(user),
                child: const Text("Assign Roles"),
              ),
            ),
          );
        },
      ),
    );
  }

  /* ================= UI ================= */
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            // Mobile: Vertical layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRolesPanel()),
                SizedBox(height: 40),
                Text(
                  "Role wise User List",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 3, 88, 6),
                  ),
                ),
                Divider(
                  height: 10,
                  thickness: 2,
                  color: const Color.fromARGB(255, 168, 231, 201),
                  indent: 2,
                  endIndent: 160,
                ),
                SizedBox(height: 5),
                Expanded(flex: 3, child: _buildUsersPanel()),
              ],
            );
          } else {
            // Tablet/Desktop: Horizontal layout
            return Row(
              children: [
                Container(
                  width: constraints.maxWidth * 0.35,
                  child: _buildRolesPanel(),
                ),
                const VerticalDivider(width: 1),
                Container(
                  width: constraints.maxWidth * 0.65,
                  child: _buildUsersPanel(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

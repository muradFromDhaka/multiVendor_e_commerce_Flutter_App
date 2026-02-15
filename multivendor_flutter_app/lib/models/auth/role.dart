class Role {
  final String roleName;

  Role({required this.roleName});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleName: json['roleName'],
    );
  }
}
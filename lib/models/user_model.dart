// lib/models/user_model.dart
enum UserRole { user, admin }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.user,
  });

  // Factory constructor to create a User from a map (e.g., from Firestore)
  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: (data['role'] == 'admin') ? UserRole.admin : UserRole.user,
    );
  }

  // Method to convert User to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.toString().split('.').last, // 'user' or 'admin'
    };
  }
}

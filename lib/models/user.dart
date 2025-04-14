class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? imagePath;
  final bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.imagePath,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'imagePath': imagePath,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      imagePath: map['imagePath'],
      isAdmin: map['isAdmin'] == 1,
    );
  }
}
class UserDart {
  final int id;
  final String uid;
  final String name;
  final String email;
  final int isAdmin;

  UserDart({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  factory UserDart.fromJson(Map<String, dynamic> json) {
    return UserDart(
        id: json['id'] as int,
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        isAdmin: json['is_admin'] as int);
  }
}

class UserAccess {
  String name;
  List<String>? access;
  UserAccess({required this.name, required this.access});

  Map<String, dynamic> toJson() => {
        'name': name,
        'access': access,
      };

  static fromJson(value) {}

  static fromMap(Map<String, dynamic> map) {
    return UserAccess(
        name: map['name'], access: List<String>.from(map['access']));
  }
}

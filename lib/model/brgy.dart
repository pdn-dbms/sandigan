class Brgy {
  final String name;
  final int voters;

  const Brgy({required this.name, required this.voters});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'voter': voters,
    };
  }

  static fromMap(Map<String, dynamic> e) {}
}

class Muni {
  final String name;
  final int voters;

  const Muni({required this.name, required this.voters});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'voter': voters,
    };
  }
}

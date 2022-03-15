class Voter {
  final String id;
  final String name;
  final String precinct;
  final String brgy;
  final String muni;
  String tagAs;
  final bool voted;

  Voter({
    required this.id,
    required this.name,
    required this.precinct,
    required this.brgy,
    required this.muni,
    required this.tagAs,
    required this.voted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'precinct': precinct,
      'brgy': brgy,
      'muni': muni,
      'tagAs': tagAs,
      'voted': voted == true ? 1 : 0,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'name': name,
      'precinct': precinct,
      'brgy': brgy,
      'muni': muni,
      'tagAs': tagAs,
      'voted': voted,
      'isUpdated': 1
    };
  }

  static Voter? fromMap(Object? data, String docId) {
    if (data == null) {
      return null;
    }
    final map = data as Map<String, dynamic>;
    return Voter(
      id: docId,
      name: map['name'] as String,
      precinct: map['precinct'] as String,
      brgy: map['brgy'] as String,
      muni: map['muni'] as String,
      tagAs: map['tagAs'] as String,
      voted: map['voted'] as bool,
    );
  }
}

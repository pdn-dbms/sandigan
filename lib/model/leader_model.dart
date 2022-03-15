class LeaderModel {
  LeaderModel({
    required this.uid,
    required this.access,
    required this.name,
    required this.contacts,
    required this.lastLocation,
  });
  late final String uid;
  late final Access access;
  late final String name;
  late final List<dynamic> contacts;
  late final LastLocation lastLocation;

  LeaderModel.fromJson(Map<String, dynamic> json) {
    access = Access.fromJson(json['access']);
    name = json['name'];
    contacts = List.castFrom<dynamic, dynamic>(json['contacts']);
    lastLocation = LastLocation.fromJson(json['last_location']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['access'] = access.toJson();
    _data['name'] = name;
    _data['contacts'] = contacts;
    _data['last_location'] = lastLocation.toJson();
    return _data;
  }
}

class Access {
  Access({
    required this.accessMuni,
    required this.accessBrgy,
    required this.accessPrecinct,
    required this.type,
  });
  late final List<dynamic> accessMuni;
  late final List<dynamic> accessBrgy;
  late final List<dynamic> accessPrecinct;
  late final String type;

  Access.fromJson(Map<String, dynamic> json) {
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['type'] = type;
    return _data;
  }
}

class LastLocation {
  LastLocation({
    required this.lat,
    required this.lng,
  });
  late final double lat;
  late final double lng;

  LastLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['lat'] = lat;
    _data['lng'] = lng;
    return _data;
  }
}

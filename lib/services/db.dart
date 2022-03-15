import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Db {
  final CollectionReference leaders =
      FirebaseFirestore.instance.collection('leaders');

  Future<void> updateUserLocation(String uid, double lat, double lng) async {
    return await leaders
        .doc(uid)
        .set({'last_location': GeoPoint(lat, lng)}, SetOptions(merge: true));
  }

  Future<void> setUserType(String uid, String type) async {
    return await leaders.doc(uid).update({'access.type': type});
  }

  Future<void> updateAccess(String uid, String access) async {
    return await leaders
        .doc(uid)
        .set({'app_access': json.decode(access)}, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Object?>> getUserAccess(String uid) async {
    return await leaders.doc(uid).get();
  }

  Future<void> addUser({required String uid, required String name}) async {
    await FirebaseFirestore.instance
        .collection('global_value')
        .doc('dashboard')
        .update({'leaders': FieldValue.increment(1)});
    return await leaders.doc(uid).set({
      'last_location': GeoPoint(0, 0),
      'name': name,
      'access': {'type': 'user'},
      'contacts': [],
      'app_access': []
    });
  }
}

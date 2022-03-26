import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/services.dart';
import "package:path/path.dart";
import 'package:pol_dbms/model/brgy.dart';
import 'package:pol_dbms/model/user_access.dart';
import 'package:pol_dbms/model/voter.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDB {
  static final SqliteDB _instance = SqliteDB.internal();

  factory SqliteDB() => _instance;

  static Database? _db;
  Future<Database> get db async => _db ??= await initDb();
  SqliteDB.internal();

  /// Initialize DB
  initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "vl_db_L7HOJ.sqlite3");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data =
          await rootBundle.load(join("assets", "vl_db_L7HOJ.sqlite3"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {}
// open the database
    var db = await openDatabase(path, readOnly: false);
    return db;
  }

  /// Count number of tables in DB

  Future<List<Voter>> getVoters(
      {required String muni, required String brgy}) async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await _db!.query('voters',
        where: 'brgy = ? and muni =  ?', whereArgs: [brgy, muni]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Voter(
          id: maps[i]['id'],
          name: maps[i]['name'],
          precinct: maps[i]['precinct'],
          brgy: maps[i]['brgy'],
          muni: maps[i]['muni'],
          tagAs: maps[i]['tagAs'],
          voted: maps[i]['voted']);
    });
  }

  Future<void> updateVoterLocal(Voter voter) async {
    // Get a reference to the database.
    final sqlite = await db;
    await sqlite.update(
      'voters',
      voter.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [voter.id],
    );
  }

  Future<void> updateLocalConfig(String key, String value) async {
    // Get a reference to the database.
    final sqlite = await db;
    Map<String, String> vals = {'key': key, 'value': value};
    //await sqlite.insert('config', vals);
    await sqlite.update(
      'config',
      vals,
      // Ensure that the Dog has a matching id.
      where: 'key = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [key],
    );
    // sqlite.update('config', vals, where: 'key = ?', whereArgs: [key]);
  }

  Future<void> updateVoter(Voter voter) async {
    // Get a reference to the database.
    final sqlite = await db;
    await sqlite.update(
      'voters',
      voter.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [voter.id],
    );

    FirebaseFirestore.instance
        .collection('voters')
        .doc(voter.id)
        .set(voter.toUpdateData(), SetOptions(merge: true));

    FirebaseFirestore.instance.collection('global_value').doc('dashboard').set(
        {'last_update': DateTime.now().millisecondsSinceEpoch},
        SetOptions(merge: true));

    if (voter.tagAs == 'ACA Supporter') {
      FirebaseFirestore.instance
          .collection('global_value')
          .doc('dashboard')
          .set(
              {'supporters': FieldValue.increment(1)}, SetOptions(merge: true));
    }
    if (voter.tagAs == 'Not Supporter') {
      FirebaseFirestore.instance
          .collection('global_value')
          .doc('dashboard')
          .set({'supporters': FieldValue.increment(-1)},
              SetOptions(merge: true));
    }
  }

  Future<List<dynamic>> getLGU() async {
    final sqlite = await db;
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await sqlite.rawQuery('SELECT DISTINCT muni as "muni" FROM voters');

    var data = [];

    for (var element in maps) {
      final List<Map<String, dynamic>> brgys = await sqlite.rawQuery(
          'SELECT DISTINCT brgy as "brgy" FROM voters where muni = ?',
          [element['muni']]);

      var brgy = <String>[];
      for (var element2 in brgys) {
        brgy.add(element2['brgy'].toString());
      }
      data.add({'name': element['muni'], 'brgy': brgy});
    }

    return data;
  }

  Future<List<String>> getMunicipalities() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await _db!.rawQuery('SELECT DISTINCT muni as "muni" FROM voters');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return maps[i]['muni'];
    });
  }

  Future<List<String>> getTags() async {
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await _db!.rawQuery('SELECT DISTINCT tagAs as "tag" FROM voters');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return maps[i]['tag'];
    });
  }

  Future<List<Voter>> getVotersByBrgy(
      {required String muni, required String brgy}) async {
    final sqlite = await db;
    final List<Map<String, dynamic>> maps = await sqlite.rawQuery(
        'SELECT *  FROM voters where muni = ? and brgy = ? order by name asc',
        [muni.toUpperCase(), brgy]);

    return List.generate(maps.length, (i) {
      return Voter(
          id: maps[i]['id'],
          name: maps[i]['name'],
          precinct: maps[i]['precinct'],
          brgy: maps[i]['brgy'],
          muni: maps[i]['muni'],
          tagAs: maps[i]['tagAs'],
          voted: maps[i]['voted'] == 1 ? true : false);
    });
  }

  Future<List<Brgy>> getBarangay({required String muni}) async {
    final sqlite = await db;
    final List<Map<String, dynamic>> maps = await sqlite.rawQuery(
        'SELECT brgy,  count(brgy) as "count" FROM voters where muni = ? group by brgy order by brgy asc',
        [muni.toUpperCase()]);

    var user = await SqliteDB().getCurrentUserInfo();
    var data = user as Map;

    if (data['access']['type'] == 'admin') {
      return List.generate(maps.length, (i) {
        return Brgy(name: maps[i]['brgy'], voters: maps[i]['count']);
      });
    } else {
      List<Brgy> brgys = [];

      List<UserAccess> userAccess =
          List.generate(data['app_access'].length, (i) {
        var _raw = data['app_access'][i] as Map;
        return UserAccess(
            name: _raw['name'], access: List.from(_raw['access']));
      });

      for (var i = 0; i < maps.length; i++) {
        final access = userAccess
            .firstWhereOrNull((element) => element.name == muni.toUpperCase());

        if (access != null) {
          if (access.access!.contains(maps[i]['brgy'])) {
            brgys.add(Brgy(name: maps[i]['brgy'], voters: maps[i]['count']));
          }
        }
      }
      return brgys;
    }
  }

  Future<Object> getMuniVLCount({required String muni}) async {
    final sqlite = await db;
    final List<Map<String, dynamic>> maps = await sqlite.rawQuery(
        'SELECT tagAs, count(muni) as "count" FROM voters where muni = ? GROUP BY tagAs',
        [muni.toUpperCase()]);
    double voters = 0;
    double supporters = 0;

    for (var i = 0; i < maps.length; i++) {
      voters = voters + double.parse(maps[i]['count'].toString());
      if (maps[i]['tagAs'] == 'ACA Supporter') {
        supporters = supporters + double.parse(maps[i]['count'].toString());
      }
    }

    return {
      'voters': voters.toString(),
      'supporters': supporters.toString(),
    };
  }

  Future<Object> getCurrentUserInfo() async {
    final sqlite = await db;
    final List<Map<String, dynamic>> maps =
        await sqlite.rawQuery('SELECT *  FROM config where key = ?', ['user']);
    return json.decode(maps[0]['value']);
  }

  Future<Object> getBrgyVLCount(
      {required String muni, required String brgy}) async {
    final sqlite = await db;
    final List<Map<String, dynamic>> maps = await sqlite.rawQuery(
        'SELECT tagAs, count(muni) as "count" FROM voters where brgy = ? and muni = ? GROUP BY tagAs',
        [brgy, muni.toUpperCase()]);
    double voters = 0;
    double supporters = 0;
    for (var i = 0; i < maps.length; i++) {
      voters = voters + double.parse(maps[i]['count'].toString());
      if (maps[i]['tagAs'] == 'ACA Supporter') {
        supporters = supporters + double.parse(maps[i]['count'].toString());
      }
    }
    return {
      'voters': voters.toString(),
      'supporters': supporters.toString(),
    };
  }
}

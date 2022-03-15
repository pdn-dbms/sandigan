import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pol_dbms/model/municipality_model.dart';

import 'municipality_screen.dart';

class PalawanMap extends StatefulWidget {
  @override
  State<PalawanMap> createState() => PalawanMapState();
}

class PalawanMapState extends State<PalawanMap>
    with AutomaticKeepAliveClientMixin<PalawanMap> {
  Completer<GoogleMapController> _controller = Completer();

  @override
  bool get wantKeepAlive => true;
  static const CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(10.665204, 119.483121),
    zoom: 8,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 10.665204,
      target: LatLng(10.665204, 119.483121),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<String> getJson() {
    return rootBundle.loadString('assets/data.json');
  }

// ignore: use_function_type_syntax_for_parameters

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getJson(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
            List<dynamic> municipalities = List.from(jsonDecode(snapshot.data));
            for (var i = 0; i < municipalities.length; i++) {
              MarkerId markerId = MarkerId(municipalities[i]['code']);
              final List<String> barangay =
                  List.from(municipalities[i]['barangay']);
              final Municipality municipality = Municipality(
                  id: municipalities[i]['code'],
                  name: municipalities[i]['value'],
                  barangay: barangay);

              Map coords = municipalities[i]['coords'] as Map;
              markers[markerId] = Marker(
                  markerId: markerId,
                  position: LatLng(coords['lat'], coords['lng']),
                  infoWindow: InfoWindow(
                      title: municipalities[i]['value'],
                      snippet: 'Registered Voter'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MunicipalityScreen(municipality: municipality))));
            }
            return GoogleMap(
              markers: Set<Marker>.of(markers.values),
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            );
          }
        });
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

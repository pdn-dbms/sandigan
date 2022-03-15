import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LastKnowLocation extends StatefulWidget {
  final double lat;
  final double lng;
  final String name;
  LastKnowLocation({required this.name, required this.lat, required this.lng});
  @override
  _LastKnowLocationState createState() => _LastKnowLocationState();
}

class _LastKnowLocationState extends State<LastKnowLocation>
    with AutomaticKeepAliveClientMixin<LastKnowLocation> {
  Completer<GoogleMapController> _controller = Completer();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: GoogleMap(
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          markers: {
            Marker(
              markerId: MarkerId("1"),
              position: LatLng(widget.lat, widget.lng),
            )
          },
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lng),
            zoom: 8,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          ].toSet()),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 10.665204,
        target: LatLng(widget.lat, widget.lng),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414)));
  }
}

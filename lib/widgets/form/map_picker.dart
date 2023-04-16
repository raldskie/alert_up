import 'package:alert_up_project/provider/location_provider.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class SelectLocation extends StatefulWidget {
  LatLng? value;
  List<LatLng>? pinnedLocations;
  Function(List<Map>) onSelectLocation;
  SelectLocation(
      {Key? key,
      this.value,
      this.pinnedLocations,
      required this.onSelectLocation})
      : super(key: key);

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  late GoogleMapController controller;
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  List<LatLng> pinnedLocs = [];
  LatLng? coordinates;

  _setMarker(LatLng pos) async {
    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 17)));

    MarkerId markerId = MarkerId(DateTime.now().toString());
    Marker destinationMarker = Marker(
      markerId: markerId,
      position: pos,
    );
    setState(() {
      markers.add(destinationMarker);
    });
  }

  _setPolygon(LatLng? pos) {
    if (pos != null) {
      pinnedLocs.add(pos);
    }

    PolygonId polygonId = const PolygonId("PolygonLoc");
    Polygon polyMarker = Polygon(
      polygonId: polygonId,
      points: pinnedLocs,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.redAccent.withOpacity(.2),
      onTap: () {},
    );
    setState(() {
      polygons.add(polyMarker);
    });
  }

  @override
  void initState() {
    coordinates = widget.value;
    pinnedLocs = widget.pinnedLocations ?? [];
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(
          height: 15,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Long press on locations to form a polygon."),
        ),
        const SizedBox(
          height: 10,
        ),
        Button(
            backgroundColor: Colors.black87,
            borderColor: Colors.transparent,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            label: "Select Location",
            onPress: () {
              if (pinnedLocs.isEmpty) {
                launchSnackbar(
                    context: context,
                    mode: "ERROR",
                    message: "No location yet.");
                return;
              }

              widget.onSelectLocation(pinnedLocs.map((e) {
                return {
                  "latitude": e.latitude,
                  "longitude": e.longitude,
                };
              }).toList());
              Navigator.pop(context);
            }),
        const SizedBox(
          height: 15,
        ),
        Expanded(
            child: GoogleMap(
          markers: markers,
          polygons: polygons,
          initialCameraPosition: CameraPosition(
            target: coordinates ??
                const LatLng(8.13361481761039, 125.12661446131358),
            zoom: 17,
          ),
          onLongPress: (argument) {
            coordinates = argument;
            _setMarker(argument);
            _setPolygon(argument);
          },
          onMapCreated: (GoogleMapController controller) {
            this.controller = controller;
            // if (widget.value != null) {
            //   _setMarker(widget.value!);
            // }

            if ((widget.pinnedLocations ?? []).isNotEmpty) {
              pinnedLocs = widget.pinnedLocations!;
              widget.pinnedLocations!.forEach((e) {
                _setMarker(e);
              });

              _setPolygon(null);
            }
          },
        )),
      ]),
    );
  }
}

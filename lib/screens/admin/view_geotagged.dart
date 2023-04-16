import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/screens/admin/view_map.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'records/geotagged_individuals.dart';

class ViewGeotagged extends StatefulWidget {
  final String dataKey;
  const ViewGeotagged({Key? key, required this.dataKey}) : super(key: key);

  @override
  State<ViewGeotagged> createState() => _ViewGeotaggedState();
}

class _ViewGeotaggedState extends State<ViewGeotagged> {
  late GoogleMapController controller;
  Set<Marker> markers = {};
  LatLng? position;
  LatLng? originalPosition;

  setMarker(LatLng pos, double pinPreset) async {
    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 17)));

    MarkerId markerId = MarkerId(DateTime.now().toString());
    Marker destinationMarker = Marker(
        markerId: markerId,
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(pinPreset));
    setState(() {
      markers.add(destinationMarker);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiseasesProvider diseasesProvider =
          Provider.of<DiseasesProvider>(context, listen: false);
      diseasesProvider.getGeotaggedIndividual(
          dataKey: widget.dataKey,
          callback: (code, message) {
            if (code != 200) {
              launchSnackbar(context: context, mode: "ERROR", message: message);
              Navigator.pop(context);
              return;
            }

            Object? value = diseasesProvider.geoTaggedIndividual!.value;
            Map geotag = value is Map ? value : {};

            double? latitude =
                double.tryParse(geotag['last_latitude'].toString());
            double? longitude =
                double.tryParse(geotag['last_longitude'].toString());

            double? detected_latitude =
                double.tryParse(geotag['detected_latitude'].toString());
            double? detected_longitude =
                double.tryParse(geotag['detected_longitude'].toString());

            if (detected_latitude != null && detected_longitude != null) {
              originalPosition = LatLng(detected_latitude, detected_longitude);
            }

            if (latitude != null && longitude != null) {
              position = LatLng(latitude, longitude);
            }
          });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    Map? getValue() {
      Object? value = diseasesProvider.geoTaggedIndividual!.value;
      return value is Map ? value : {};
    }

    return diseasesProvider.loading == "geotagged"
        ? Center(child: PumpingAnimation())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    markers: markers,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(8.13361481761039, 125.12661446131358),
                      zoom: 17,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      this.controller = controller;
                      if (position != null) {
                        controller.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(target: position!, zoom: 12)));
                        setMarker(position!, BitmapDescriptor.hueGreen);
                      }
                      if (originalPosition != null) {
                        setMarker(originalPosition!, BitmapDescriptor.hueRed);
                      }
                    },
                  )),
              const SizedBox(height: 10),
              Row(children: [
                Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                const Text("Last Location",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 30),
                Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                const Text("Geotagged Location",
                    style: TextStyle(color: Colors.grey, fontSize: 12))
              ]),
              const Divider(),
              const SizedBox(height: 20),
              Image.network(
                (getValue()?['imageUrl'] ?? "").isNotEmpty
                    ? getValue()!['imageUrl']
                    : USER_PLACEHOLDER_IMAGE,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(getValue()?['name'] ?? "Anonymous",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(getValue()?['gender'] ?? ""),
                ]),
                StatusBadge(
                    color:
                        (getValue()?['status'] ?? "").toLowerCase() == "tagged"
                            ? Colors.red
                            : const Color.fromARGB(255, 66, 65, 65),
                    label: getValue()?['status'] ?? "No Status"),
              ]),
              const SizedBox(height: 20),
              const Text("Purok",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(getValue()?['purok'] ?? "No info."),
              const SizedBox(height: 20),
              const Text("Contact No.",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text((getValue()?['contact'] ?? "").isNotEmpty
                  ? "+63${getValue()?['contact']}"
                  : "No contact no."),
              const SizedBox(height: 20)
            ]));
  }
}

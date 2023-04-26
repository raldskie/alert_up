import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/screens/admin/view_map.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ViewClassifiedZone extends StatefulWidget {
  final String dataKey;
  const ViewClassifiedZone({Key? key, required this.dataKey}) : super(key: key);

  @override
  State<ViewClassifiedZone> createState() => _ViewClassifiedZoneState();
}

class _ViewClassifiedZoneState extends State<ViewClassifiedZone> {
  late GoogleMapController controller;
  Set<Polygon> polygons = {};
  List<LatLng> pinnedLocations = [];

  void setPolygon(String? dataKey, List<LatLng> pinnedLocs) {
    PolygonId polygonId = PolygonId(dataKey ?? DateTime.now().toString());
    Polygon polyMarker = Polygon(
      polygonId: polygonId,
      points: pinnedLocs,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.redAccent.withOpacity(.2),
      onTap: () {},
    );
    polygons.add(polyMarker);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiseasesProvider diseasesProvider =
          Provider.of<DiseasesProvider>(context, listen: false);
      diseasesProvider.getClassifiedZone(
          key: widget.dataKey,
          callback: (code, message) {
            if (code != 200) {
              launchSnackbar(context: context, mode: "ERROR", message: message);
              Navigator.pop(context);
              return;
            }

            (((diseasesProvider.classifiedZone!.value
                        as Map)['pinnedLocations'] ??
                    []) as List)
                .forEach((e) {
              pinnedLocations.add(LatLng(e['latitude'], e['longitude']));
            });

            if (pinnedLocations.isNotEmpty) {
              setPolygon(null, pinnedLocations);
            }
          });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    Map? getValue() {
      Object? value = diseasesProvider.classifiedZone!.value;
      return value is Map ? value : {};
    }

    return diseasesProvider.loading == "c_zone"
        ? Center(child: PumpingAnimation())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(8.13361481761039, 125.12661446131358),
                      zoom: 17,
                    ),
                    polygons: polygons,
                    onMapCreated: (GoogleMapController controller) {
                      this.controller = controller;
                      if (pinnedLocations.isNotEmpty) {
                        controller.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                                target: pinnedLocations[0], zoom: 17)));
                      }
                    },
                  )),
              const SizedBox(height: 15),
              const Text(
                "Purok",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                getValue()?['purokName'] ?? "No data",
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 15),
              const Text(
                "Barangay",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                getValue()?['barangay'] ?? "No data",
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 15),
              Text(
                getValue()?['Geo_Name'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                getValue()?['Description'],
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 15),
              const Text(
                "Alert Message",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              Text(
                getValue()?['alert_message'],
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 100),
            ]));
  }
}

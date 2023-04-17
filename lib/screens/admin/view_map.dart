import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/screens/admin/view_classified_zone.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/bottom_modal.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:point_in_polygon/point_in_polygon.dart';
import 'package:provider/provider.dart';

class ViewMap extends StatefulWidget {
  ViewMap({Key? key}) : super(key: key);

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  String fetchMode = "CLASSIFIED"; //GEOTAGGED
  late GoogleMapController controller;
  Set<Circle> circles = {};
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};

  setMarker(LatLng pos) async {
    controller.animateCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(
            target: LatLng(8.13361481761039, 125.12661446131358), zoom: 15)));

    MarkerId markerId = MarkerId(DateTime.now().toString());
    Marker destinationMarker = Marker(markerId: markerId, position: pos);
    setState(() {
      markers.add(destinationMarker);
    });
  }

  void setPolygon(String? dataKey, List<LatLng> pinnedLocs) {
    controller.animateCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(
            target: LatLng(8.13361481761039, 125.12661446131358), zoom: 15)));
    final List<Point> points = <Point>[
      ...pinnedLocs.map((e) => Point(y: e.latitude, x: e.longitude))
    ];

    int diseaseCount = 0;
    DiseasesProvider diseasesProvider =
        Provider.of<DiseasesProvider>(context, listen: false);

    diseasesProvider.geotaggedIndividuals.forEach((e) {
      Map geotag = (e.value ?? {}) as Map;
      double? latitude = double.tryParse(geotag['last_latitude'].toString());
      double? longitude = double.tryParse(geotag['last_longitude'].toString());
      if (latitude != null && longitude != null) {
        bool isInside =
            Poly.isPointInPolygon(Point(x: longitude, y: latitude), points);
        if (isInside) diseaseCount += 1;
      }
    });

    Color polyColor = Colors.red;

    if (diseaseCount < 10) {
      polyColor = Colors.green;
    }

    if (diseaseCount > 10 && diseaseCount <= 20) {
      polyColor = Colors.orange;
    }

    PolygonId polygonId = PolygonId(dataKey ?? DateTime.now().toString());
    Polygon polyMarker = Polygon(
      polygonId: polygonId,
      points: pinnedLocs,
      strokeWidth: 2,
      strokeColor: polyColor,
      fillColor: polyColor.withOpacity(.2),
      consumeTapEvents: true,
      onTap: () {
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                return Modal(
                    title: "Classified Zone",
                    heightInPercentage: .9,
                    content: ViewClassifiedZone(dataKey: dataKey!));
              });
            });
      },
    );
    polygons.add(polyMarker);
  }

  getClassified() {
    markers = {};
    DiseasesProvider diseasesProvider =
        Provider.of<DiseasesProvider>(context, listen: false);

    diseasesProvider.getGeotaggedList(callback: (code, message) {
      if (code == 200) {
        diseasesProvider.getClassifiedZones(callback: (code, message) {
          if (code == 200) {
            diseasesProvider.classifiedZones.forEach((e) {
              try {
                List<LatLng> pinnedLocations = [];
                (((e.value as Map)['pinnedLocations'] ?? []) as List)
                    .forEach((e) {
                  pinnedLocations.add(LatLng(e['latitude'], e['longitude']));
                });
                if (pinnedLocations.isNotEmpty) {
                  setPolygon(e.key, pinnedLocations);
                }
              } catch (e) {
                print(e);
              }
              setState(() {});
            });
          }
        });
      }
    });
  }

  getGeotagged() {
    polygons = {};
    DiseasesProvider diseasesProvider =
        Provider.of<DiseasesProvider>(context, listen: false);

    diseasesProvider.getGeotaggedList(callback: (code, message) {
      if (code == 200) {
        diseasesProvider.geotaggedIndividuals.forEach((e) {
          Map geotag = (e.value ?? {}) as Map;
          double? latitude =
              double.tryParse(geotag['last_latitude'].toString());
          double? longitude =
              double.tryParse(geotag['last_longitude'].toString());
          if (latitude != null && longitude != null) {
            setMarker(LatLng(latitude, longitude));
          }
        });
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getClassified();
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    return Stack(children: [
      Column(children: [
        Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                const Text("High risk area",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 20),
                Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                const Text("Medium risk area",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 20),
                Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 10),
                const Text("Low risk area",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            )),
        Expanded(
            child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(8.13361481761039, 125.12661446131358),
            zoom: 17,
          ),
          circles: circles,
          markers: markers,
          polygons: polygons,
          onMapCreated: (GoogleMapController controller) {
            this.controller = controller;
          },
        )),
      ]),
      if (["classified_list", "geotagged_list"]
          .contains(diseasesProvider.loading))
        Center(child: PumpingAnimation()),
      Positioned(
        bottom: 0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          scrollDirection: Axis.horizontal,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ActionChip(
              avatar: Icon(
                Icons.map_rounded,
                color: fetchMode == "CLASSIFIED" ? Colors.white : Colors.grey,
                size: 15,
              ),
              label: Text(
                "Classified Zones",
                style: TextStyle(
                    color:
                        fetchMode == "CLASSIFIED" ? Colors.white : Colors.grey,
                    fontSize: 12),
              ),
              backgroundColor:
                  fetchMode == "CLASSIFIED" ? ACCENT_COLOR : Colors.white,
              elevation: 3,
              onPressed: () {
                setState(() {
                  fetchMode = "CLASSIFIED";
                });

                getClassified();
              },
            ),
            const SizedBox(width: 15),
            ActionChip(
              avatar: Icon(
                Icons.person_pin_rounded,
                color: fetchMode == "GEOTAGGED" ? Colors.white : Colors.grey,
                size: 15,
              ),
              label: Text(
                "Geotagged",
                style: TextStyle(
                    color:
                        fetchMode == "GEOTAGGED" ? Colors.white : Colors.grey,
                    fontSize: 12),
              ),
              backgroundColor:
                  fetchMode == "GEOTAGGED" ? ACCENT_COLOR : Colors.white,
              elevation: 3,
              onPressed: () {
                setState(() {
                  fetchMode = "GEOTAGGED";
                });
                getGeotagged();
              },
            )
          ]),
        ),
      )
    ]);
  }
}

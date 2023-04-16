import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/screens/admin/view_classified_zone.dart';
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
  late GoogleMapController controller;
  Set<Circle> circles = {};
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};

  void setPolygon(String? dataKey, List<LatLng> pinnedLocs) {
    final List<Point> points = <Point>[
      ...pinnedLocs.map((e) => Point(y: e.latitude, x: e.longitude))
    ];

    PolygonId polygonId = PolygonId(dataKey ?? DateTime.now().toString());
    Polygon polyMarker = Polygon(
      polygonId: polygonId,
      points: pinnedLocs,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.redAccent.withOpacity(.2),
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DiseasesProvider diseasesProvider =
          Provider.of<DiseasesProvider>(context, listen: false);

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

            // dynamic latitude =
            //     double.tryParse(((e.value ?? {}) as Map)['latitude'] ?? "");
            // dynamic longitude =
            //     double.tryParse(((e.value ?? {}) as Map)['longitude'] ?? "");
            // if (latitude != null && latitude != null) {
            //   addCirclesWithRadius(LatLng(latitude, longitude), 30);
            //   addMarkerWithRadius(LatLng(latitude, longitude));
            // }
          });
        }
      });
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

    return diseasesProvider.loading == "classified_list"
        ? Center(child: PumpingAnimation())
        : GoogleMap(
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
          );
  }
}

import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/provider/user_provider.dart';
import 'package:alert_up_project/screens/user/user_device_id.dart';
import 'package:alert_up_project/utilities/calc_coords_dist.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:point_in_polygon/point_in_polygon.dart';
import 'package:provider/provider.dart';

class GeoFence extends StatefulWidget {
  GeoFence({Key? key}) : super(key: key);

  @override
  State<GeoFence> createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence> {
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  late GoogleMapController controller;
  LocationData? currentLocation;
  dynamic areaDiseaseData;
  String? deviceId;

  LatLng? enterPos;
  LatLng? exitPos;

  _setMarker({String? markerID, required LatLng pos}) async {
    MarkerId markerId = MarkerId(markerID ?? DateTime.now().toString());
    Marker destinationMarker = Marker(
      markerId: markerId,
      position: pos,
    );
    setState(() {
      markers.add(destinationMarker);
    });
  }

  void getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.enableBackgroundMode(enable: true);
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        checkIfInside(LatLng(newLoc.latitude!, newLoc.longitude!));
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 17,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );

        _setMarker(
            markerID: "CURRENT_POS",
            pos: LatLng(newLoc.latitude!, newLoc.longitude!));

        UserProvider diseasesProvider =
            Provider.of<UserProvider>(context, listen: false);

        if (deviceId != null) {
          diseasesProvider
              .updateLocationOfTaggedPerson(deviceId: deviceId!, payload: {
            "last_latitude": newLoc.latitude,
            "last_longitude": newLoc.longitude,
          });
        }
      },
    );
  }

  bool checkIfInside(LatLng currentPost) {
    return polygons.any((poly) {
      final List<Point> points = <Point>[
        ...poly.points.map((e) => Point(y: e.latitude, x: e.longitude))
      ];

      bool isInside = Poly.isPointInPolygon(
          Point(x: currentPost.longitude, y: currentPost.latitude), points);

      if (isInside) {
        DiseasesProvider diseasesProvider =
            Provider.of<DiseasesProvider>(context, listen: false);
        areaDiseaseData = diseasesProvider.classifiedZones
            .lastWhere((e) => e.key == poly.polygonId.value)
            .value;
        areaDiseaseData = (areaDiseaseData ?? {}) as Map;
        _showNotification(
            title: "ENTERED IN A CLASSIFIED AREA",
            message: areaDiseaseData['alert_message']);
        Provider.of<UserProvider>(context, listen: false)
            .hasEnteredClassifiedArea(payload: {
          "deviceId": deviceId,
          "last_latitude": currentPost.latitude,
          "last_longitude": currentPost.longitude,
          "diseaseKey": poly.polygonId.value
        }, callback: (code, message) {});

        enterPos ??= currentPost;
        exitPos = currentPost;

        double distance =
            double.parse(calculateDistance(currentPost, enterPos!));

        if (distance == 0.0) {
          AudioPlayer().play(AssetSource('sounds/enter.mp3'));
        }

        // if (distance > .01 && distance < .02) {
        //   AudioPlayer().play(AssetSource('sounds/alert.mp3'));
        // }
        print(
            "calculateDistance ENTER ${double.parse(calculateDistance(currentPost, enterPos!))}");
      }

      // else {
      //   if (exitPos != null &&
      //       double.parse(calculateDistance(currentPost, exitPos!)) == 0) {
      //     print(
      //         "calculateDistance EXIT ${double.parse(calculateDistance(currentPost, exitPos!))}");
      //     AudioPlayer().play(AssetSource('sounds/exit.mp3'));
      //     enterPos = null;
      //     exitPos = null;
      //   }
      // }

      return isInside;
    });
  }

  void setPolygon(String? polygonID, List<LatLng> pinnedLocs) {
    PolygonId polygonId = PolygonId(polygonID ?? DateTime.now().toString());
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

  Future<void> _showNotification(
      {required String title, required String message}) async {
    var androidDetails = const AndroidNotificationDetails(
        'channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.high,
        priority: Priority.high,
        icon: "@mipmap/ic_launcher",
        actions: [AndroidNotificationAction("ACK_ALERT", "ACKNOWLEDGE ALERT")],
        ticker: 'test');
    // Acknowledge Alert
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .show(0, title, message, generalNotificationDetails, payload: 'test');
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DiseasesProvider diseasesProvider =
          Provider.of<DiseasesProvider>(context, listen: false);

      deviceId = await PlatformDeviceId.getDeviceId;

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

    return Scaffold(
      appBar:
          customAppBar(context, title: "Alert Up", centerTitle: true, actions: [
        Button(
            icon: Icons.person_pin,
            label: "Your ID",
            borderColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            textColor: ACCENT_COLOR,
            onPress: () async {
              // final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
              // var build = await deviceInfoPlugin.androidInfo;
              // String uniqueId = build.id;
              String? deviceId = await PlatformDeviceId.getDeviceId;
              if (!mounted) return;
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                        child: UserDeviceId(
                          uniqueId: deviceId!,
                        ),
                      ));
            })
      ]),
      body: diseasesProvider.loading == "classified_list"
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(8.13361481761039, 125.12661446131358),
                zoom: 17,
              ),
              markers: markers,
              polygons: polygons,
              onMapCreated: (GoogleMapController controller) {
                this.controller = controller;
                getCurrentLocation();
              },
            ),
    );
  }
}

// https://pub.dev/packages/point_in_polygon
// https://medium.com/dlt-labs-publication/flutter-run-code-in-the-background-461b4d6c635b
// https://pub.dev/packages/flutter_local_notifications
// https://medium.com/flutter-community/flutter-google-map-with-live-location-tracking-uber-style-12da38771829
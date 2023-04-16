import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserDeviceId extends StatefulWidget {
  String uniqueId;
  UserDeviceId({Key? key, required this.uniqueId}) : super(key: key);

  @override
  State<UserDeviceId> createState() => _UserDeviceIdState();
}

class _UserDeviceIdState extends State<UserDeviceId> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: QrImage(
        data: widget.uniqueId,
        version: QrVersions.auto,
        size: 200,
      ),
    );
  }
}

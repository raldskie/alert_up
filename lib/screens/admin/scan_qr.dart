import 'package:alert_up_project/screens/admin/view_geotagged.dart';
import 'package:alert_up_project/widgets/bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends StatefulWidget {
  final String purpose;
  const QRScanner({Key? key, required this.purpose}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner>
    with SingleTickerProviderStateMixin {
  String? qrCode;
  MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
  );
  bool isStarted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Alert UP"),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // For iOS (dark icons)
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: .5,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                allowDuplicates: true,
                onDetect: (barcode, args) {
                  if (qrCode != barcode.rawValue) {
                    qrCode = barcode.rawValue;
                    if (widget.purpose == "ADD_GEOTAG") {
                      Navigator.pushNamed(context, "/geotag/form", arguments: {
                        "uniqueId": qrCode,
                        "mode": "ADD",
                      }).then((value) => qrCode = null);
                    }
                    if (widget.purpose == "TRACK_GEOTAG") {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          enableDrag: false,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setModalState) {
                              return Modal(
                                  title: "Geotagged",
                                  heightInPercentage: .9,
                                  content: ViewGeotagged(dataKey: qrCode!));
                            });
                          });
                    }
                  }
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  padding: const EdgeInsets.all(20),
                  color: Colors.black.withOpacity(0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder(
                          valueListenable: controller.torchState,
                          builder: (context, state, child) {
                            if (state == null) {
                              return const Icon(
                                Icons.flash_off,
                                color: Colors.grey,
                              );
                            }
                            switch (state as TorchState) {
                              case TorchState.off:
                                return const Icon(
                                  Icons.flash_off,
                                  color: Colors.grey,
                                );
                              case TorchState.on:
                                return const Icon(
                                  Icons.flash_on,
                                  color: Colors.yellow,
                                );
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.toggleTorch(),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: isStarted
                            ? const Icon(Icons.stop)
                            : const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed: () => setState(() {
                          isStarted ? controller.stop() : controller.start();
                          isStarted = !isStarted;
                        }),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder(
                          valueListenable: controller.cameraFacingState,
                          builder: (context, state, child) {
                            if (state == null) {
                              return const Icon(Icons.camera_front);
                            }
                            switch (state as CameraFacing) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.switchCamera(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/screens/admin/view_geotagged.dart';
import 'package:alert_up_project/utilities/constants.dart';
import 'package:alert_up_project/widgets/bottom_modal.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeoTaggedIndividuals extends StatefulWidget {
  GeoTaggedIndividuals({Key? key}) : super(key: key);

  @override
  State<GeoTaggedIndividuals> createState() => _GeoTaggedIndividualsState();
}

class _GeoTaggedIndividualsState extends State<GeoTaggedIndividuals> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiseasesProvider>(context, listen: false)
          .getGeotaggedList(callback: (code, message) {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    if (diseasesProvider.loading == "geotagged_list") {
      return Center(child: PumpingAnimation());
    }
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 30),
        itemCount: diseasesProvider.geotaggedIndividuals.length,
        itemBuilder: (context, index) {
          Object? value = diseasesProvider.geotaggedIndividuals[index].value;
          Map geotagged = value is Map ? value : {};

          return InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter setModalState) {
                      return Modal(
                          title: "Geotagged",
                          heightInPercentage: .9,
                          content: ViewGeotagged(
                              dataKey: diseasesProvider
                                  .geotaggedIndividuals[index].key!));
                    });
                  });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            (geotagged['imageUrl'] ?? "").isNotEmpty
                                ? geotagged['imageUrl']
                                : USER_PLACEHOLDER_IMAGE,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(),
                          ),
                          const SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(geotagged['name'] ?? "Anonymous",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(geotagged['gender'] ?? "")
                              ]),
                          Expanded(child: Container()),
                          StatusBadge(
                              color:
                                  (geotagged['status'] ?? "").toLowerCase() ==
                                          "tagged"
                                      ? Colors.red
                                      : const Color.fromARGB(255, 66, 65, 65),
                              label: geotagged['status'] ?? "No Status")
                        ]),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Contact No.",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text((geotagged['contact'] ?? "").isNotEmpty
                                    ? "+63${geotagged['contact']}"
                                    : "No contact no."),
                              ]),
                          Button(
                            label: "Edit",
                            textColor: Colors.black,
                            borderColor: Colors.black,
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            onPress: () => Navigator.pushNamed(
                                context, '/geotag/form', arguments: {
                              'dataKey': diseasesProvider
                                  .geotaggedIndividuals[index].key,
                              'mode': 'EDIT'
                            }),
                          )
                        ])
                  ]),
            ),
          );
        });
  }
}

class StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  const StatusBadge({Key? key, required this.color, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

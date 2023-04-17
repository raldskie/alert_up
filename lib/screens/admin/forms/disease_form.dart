import 'dart:math';

import 'package:alert_up_project/provider/diseases_provider.dart';
import 'package:alert_up_project/widgets/button.dart';
import 'package:alert_up_project/widgets/custom_app_bar.dart';
import 'package:alert_up_project/widgets/form/form_theme.dart';
import 'package:alert_up_project/widgets/simple_dialog.dart';
import 'package:alert_up_project/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiseaseForm extends StatefulWidget {
  String? dataKey;
  String mode;
  DiseaseForm({Key? key, this.dataKey, required this.mode}) : super(key: key);

  @override
  State<DiseaseForm> createState() => _DiseaseFormState();
}

class _DiseaseFormState extends State<DiseaseForm> {
  Map payload = {
    "alert_message": "",
    "disease_description": "",
    "disease_name": ""
  };

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == "EDIT") {
        DiseasesProvider diseasesProvider =
            Provider.of<DiseasesProvider>(context, listen: false);
        diseasesProvider.getDisease(
            key: widget.dataKey!,
            callback: (code, message) {
              if (code == 200) {
                payload = (diseasesProvider.disease?.value ?? {}) as Map;
                return;
              }
              // launchSnackbar(
              //     context: context,
              //     mode: code == 200 ? "SUCCESS" : "ERROR",
              //     message: message);
              Navigator.pop(context);
            });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiseasesProvider diseasesProvider = context.watch<DiseasesProvider>();

    return Scaffold(
      appBar: customAppBar(context,
          title: widget.mode == "EDIT" ? "Edit Disease" : "Add Disease",
          centerTitle: true,
          actions: [
            if (widget.mode == "EDIT") ...[
              Button(
                isLoading: diseasesProvider.loading == "delete_disease",
                icon: Icons.backspace_rounded,
                label: "Delete",
                borderColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                textColor: Colors.red,
                onPress: () {
                  dialogWithAction(context,
                      title: "Are you sure?",
                      description: "This will delete this data forever.",
                      actions: [
                        Button(
                            label: "Yes, please proceed.",
                            onPress: () {
                              diseasesProvider.deleteDisease(
                                  loading: "delete_disease",
                                  key: diseasesProvider.disease?.key ?? "",
                                  callback: (code, message) {
                                    launchSnackbar(
                                        context: context,
                                        mode: code == 200 ? "SUCCESS" : "ERROR",
                                        message: message);

                                    if (code == 200) {
                                      Navigator.pop(context);
                                    }
                                  });
                            })
                      ]);
                },
              )
            ]
          ]),
      body: diseasesProvider.loading == "disease"
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                  child: Column(children: [
                const SizedBox(height: 50),
                TextFormField(
                    initialValue: payload['disease_name'],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Field required";
                      }
                    },
                    onChanged: (val) =>
                        setState(() => payload['disease_name'] = val),
                    decoration: textFieldStyle(label: "Disease Name")),
                const SizedBox(height: 20),
                TextFormField(
                    initialValue: payload['disease_description'],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Field required";
                      }
                    },
                    maxLines: null,
                    onChanged: (val) =>
                        setState(() => payload['disease_description'] = val),
                    decoration: textFieldStyle(label: "Disease Description")),
                const SizedBox(height: 20),
                TextFormField(
                    initialValue: payload['alert_message'],
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Field required";
                      }
                    },
                    maxLines: null,
                    onChanged: (val) =>
                        setState(() => payload['alert_message'] = val),
                    decoration: textFieldStyle(label: "Alert Message")),
                const SizedBox(height: 20),
                Button(
                    isLoading: ["disease_add", "disease_edit"]
                        .contains(diseasesProvider.loading),
                    label:
                        widget.mode == "EDIT" ? "Add Disease" : "Save Changes",
                    onPress: () {
                      if (widget.mode == "ADD") {
                        diseasesProvider.addDisease(
                            payload: payload,
                            callback: (code, message) {
                              launchSnackbar(
                                  context: context,
                                  mode: code == 200 ? "SUCCESS" : "ERROR",
                                  message: message);

                              if (code == 200) {
                                Navigator.pop(context);
                              }
                            });
                      } else {
                        diseasesProvider.updateDisease(
                            key: widget.dataKey!,
                            payload: payload,
                            callback: (code, message) {
                              launchSnackbar(
                                  context: context,
                                  mode: code == 200 ? "SUCCESS" : "ERROR",
                                  message: message);
                              if (code == 200) {
                                Navigator.pop(context);
                              }
                            });
                      }
                    }),
                const SizedBox(height: 15)
              ])),
            ),
    );
  }
}

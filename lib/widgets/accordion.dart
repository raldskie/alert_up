import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:flutter/material.dart';

class Accordion extends StatefulWidget {
  final String title;
  final String? value;
  final Widget content;
  final IconData? titleIcon;

  const Accordion(
      {Key? key,
      this.titleIcon,
      required this.title,
      required this.content,
      this.value})
      : super(key: key);
  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool _showContent = false;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconText(
              icon: widget.titleIcon,
              label: widget.title,
              size: 15,
            ),
            if ((widget.value ?? "").isNotEmpty)
              IconText(
                label: widget.value ?? "",
                fontWeight: FontWeight.bold,
              ),
          ]),
          IconButton(
            icon: Icon(
                _showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: () {
              setState(() {
                _showContent = !_showContent;
              });
            },
          )
        ]),
      ),
      _showContent ? widget.content : Container()
    ]);
  }
}

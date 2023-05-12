import 'package:alert_up_project/utilities/constants.dart';
import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  MainAxisAlignment? mainAxisAlignment;
  double? textWidthInPercentage;
  IconData? icon;
  String label;
  double? size;
  Color? color;
  FontWeight? fontWeight;
  EdgeInsets? padding;
  Color? backgroundColor;
  double? borderRadius;
  double? width;
  double? height;
  bool? isLoading;
  IconText(
      {Key? key,
      this.icon,
      required this.label,
      this.size,
      this.width,
      this.height,
      this.color,
      this.fontWeight,
      this.mainAxisAlignment,
      this.backgroundColor,
      this.borderRadius,
      this.textWidthInPercentage,
      this.isLoading,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius ?? 0)),
      padding: padding ?? const EdgeInsets.all(0),
      child: Row(
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          children: [
            if (isLoading ?? false)
              SizedBox(
                  height: size ?? 13,
                  width: size ?? 13,
                  child: CircularProgressIndicator(
                    color: color ?? ACCENT_COLOR,
                    strokeWidth: 2,
                  ))
            else if (icon != null)
              Icon(
                icon,
                size: (size ?? 13),
                color: color ?? Colors.black,
              ),
            if (icon != null || isLoading != null) const SizedBox(width: 5),
            SizedBox(
              width: textWidthInPercentage != null
                  ? MediaQuery.of(context).size.width * textWidthInPercentage!
                  : null,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                    fontSize: (size ?? 13),
                    color: color ?? Colors.black,
                    fontWeight: fontWeight ?? FontWeight.normal),
              ),
            )
          ]),
    );
  }
}

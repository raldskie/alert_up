import 'package:alert_up_project/utilities/constants.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  bool? isLoading;
  IconData? icon;
  IconData? rightIcon;
  String label;
  Color? backgroundColor;
  Color? textColor;
  Color? borderColor;
  Function? onPress;
  Function? onLongPress;
  EdgeInsets? padding;
  // bool? disabled;
  double? borderRadius;
  EdgeInsets? margin;
  double? fontSize;
  MainAxisAlignment? mainAxisAlignment;
  FontWeight? fontWeight;
  bool? displayMode;
  bool? isTextExpanded;

  Button(
      {Key? key,
      this.icon,
      this.isLoading = false,
      required this.label,
      this.onPress,
      this.onLongPress,
      this.backgroundColor,
      this.borderColor,
      this.padding,
      // this.disabled,
      this.borderRadius,
      this.margin,
      this.fontSize,
      this.rightIcon,
      this.mainAxisAlignment,
      this.fontWeight,
      this.textColor,
      this.displayMode,
      this.isTextExpanded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = Text(label,
        textAlign: TextAlign.left,
        maxLines: 1,
        style: TextStyle(
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize ?? 14,
          letterSpacing: 0.27,
          color: textColor ?? Colors.white,
        ));

    return Opacity(
      opacity:
          !(displayMode ?? false) && (onPress == null && onLongPress == null)
              ? 0.5
              : 1,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
            gradient: backgroundColor == null
                ? const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 234, 29, 29),
                      Color.fromARGB(255, 239, 93, 25),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: backgroundColor ?? ACCENT_COLOR,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 5)),
            border: Border.all(color: borderColor ?? ACCENT_COLOR)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 5)),
            onLongPress: (onLongPress == null || isLoading!)
                ? null
                : () => onLongPress!(),
            onTap: (onPress == null || isLoading!) ? null : () => onPress!(),
            child: Padding(
              padding: padding ??
                  const EdgeInsets.only(
                      top: 12, bottom: 12, left: 18, right: 18),
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      mainAxisAlignment ?? MainAxisAlignment.center,
                  children: [
                    if (isLoading!)
                      SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: textColor ?? Colors.white,
                          strokeWidth: 1,
                        ),
                      ),
                    if (icon != null && !isLoading!)
                      Icon(
                        icon,
                        color: textColor ?? Colors.white,
                        size: fontSize ?? 14,
                      ),
                    if (icon != null || isLoading!)
                      SizedBox(
                        width: isLoading! ? 15 : 10,
                      ),
                    (isTextExpanded ?? false) ? Expanded(child: text) : text,
                    if (rightIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 7),
                        child: Icon(
                          rightIcon,
                          color: textColor ?? Colors.white,
                          size: fontSize ?? 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

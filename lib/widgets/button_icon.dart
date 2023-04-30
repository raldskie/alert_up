import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  final double? size;
  final double? iconSize;
  final Color? bgColor;
  final Color? iconColor;
  final IconData icon;
  final Function onPress;
  final String? tooltip;
  final bool? isLoading;
  const ButtonIcon({
    Key? key,
    this.size,
    this.iconSize,
    this.bgColor,
    this.iconColor,
    this.tooltip,
    this.isLoading,
    required this.icon,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? "",
      child: SizedBox(
        height: size ?? 40,
        width: size ?? 40,
        child: Material(
            borderRadius: BorderRadius.circular(100),
            clipBehavior: Clip.hardEdge,
            color: bgColor ?? Colors.black38,
            child: (isLoading ?? false)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                        color: iconColor ?? Colors.white, strokeWidth: 2),
                  )
                : IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => onPress(),
                    icon: Icon(
                      icon,
                      color: iconColor ?? Colors.white,
                      size: iconSize ?? 20,
                    ))),
      ),
    );
  }
}

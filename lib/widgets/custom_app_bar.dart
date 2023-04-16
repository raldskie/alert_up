import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppBar customAppBar(context,
    {dynamic title,
    dynamic closeIcon,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? foregroundColor,
    bool? automaticallyImplyLeading,
    double? elevation,
    bool? centerTitle,
    bool? hideLeading,
    double? toolbarHeight,
    SystemUiOverlayStyle? systemOverlayStyle}) {
  getLeading() {
    if (hideLeading ?? false) return null;

    return closeIcon is IconData
        ? IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              closeIcon,
              size: 25,
            ),
          )
        : closeIcon;
  }

  return AppBar(
    automaticallyImplyLeading: automaticallyImplyLeading ?? true,
    leading: getLeading(),
    title: title == null
        ? null
        : title is String
            ? Text(
                title,
                style: const TextStyle(fontSize: 17),
              )
            : title,
    toolbarHeight: toolbarHeight,
    systemOverlayStyle: systemOverlayStyle,
    centerTitle: centerTitle,
    flexibleSpace: flexibleSpace,
    bottom: bottom,
    actions: actions,
    backgroundColor: backgroundColor ?? Colors.white,
    foregroundColor: foregroundColor ?? Colors.black,
    elevation: elevation ?? .5,
  );
}

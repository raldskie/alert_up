import 'package:alert_up_project/widgets/icon_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'button_icon.dart';

class ImageViewer extends StatefulWidget {
  List<String> photos;
  int index;
  ImageViewer({Key? key, required this.photos, required this.index})
      : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int index = 0;
  int prevIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    index = widget.index;
    pageController = PageController(initialPage: widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [
          !kIsWeb
              ? PhotoViewGallery.builder(
                  pageController: pageController,
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(widget.photos[index]));
                  },
                  itemCount: widget.photos.length,
                  onPageChanged: (ind) => setState(() {
                    index = ind;
                  }),
                  loadingBuilder: (context, event) {
                    return Center(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                        ),
                      ),
                    );
                  },
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    late final inAnimation;
                    late final outAnimation;

                    if (index > prevIndex) {
                      inAnimation = Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: const Offset(0.0, 0.0))
                          .animate(animation);
                      outAnimation = Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
                              end: const Offset(0.0, 0.0))
                          .animate(animation);
                    } else {
                      inAnimation = Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
                              end: const Offset(0.0, 0.0))
                          .animate(animation);
                      outAnimation = Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: const Offset(0.0, 0.0))
                          .animate(animation);
                    }

                    if (child.key == ValueKey(index)) {
                      return ClipRect(
                        child: SlideTransition(
                          position: inAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: child,
                          ),
                        ),
                      );
                    } else {
                      return ClipRect(
                        child: SlideTransition(
                          position: outAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: child,
                          ),
                        ),
                      );
                    }
                  },
                  child: Center(
                      key: ValueKey<int>(index),
                      child: PhotoView(
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        imageProvider: NetworkImage(widget.photos[index]),
                        loadingBuilder: (context, event) => Center(
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded /
                                      event.expectedTotalBytes!,
                            ),
                          ),
                        ),
                      )),
                ),
          if (kIsWeb)
            Positioned(
                left: 15,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  child: Material(
                      borderRadius: BorderRadius.circular(100),
                      clipBehavior: Clip.hardEdge,
                      color: index == 0
                          ? Colors.white.withOpacity(.1)
                          : Colors.white,
                      child: IconButton(
                          onPressed: () {
                            if (index == 0) {
                              return;
                            }

                            setState(() {
                              prevIndex = index;
                              index -= 1;
                            });
                          },
                          icon: const Icon(Icons.arrow_left_outlined))),
                )),
          if (kIsWeb)
            Positioned(
                right: 15,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  child: Material(
                      borderRadius: BorderRadius.circular(100),
                      clipBehavior: Clip.hardEdge,
                      color: index == widget.photos.length - 1
                          ? Colors.white.withOpacity(.1)
                          : Colors.white,
                      child: IconButton(
                          onPressed: () {
                            if (index == widget.photos.length - 1) {
                              return;
                            }

                            setState(() {
                              prevIndex = index;
                              index += 1;
                            });
                          },
                          icon: const Icon(Icons.arrow_right_outlined))),
                )),
          Positioned(
              bottom: 15,
              right: 15,
              child: IconText(
                label: "${index + 1}/${widget.photos.length}",
                backgroundColor: Colors.white,
                borderRadius: 100,
                fontWeight: FontWeight.bold,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              )),
          Positioned(
              top: 15,
              right: 15,
              child: ButtonIcon(
                  icon: Icons.close,
                  bgColor: Colors.white,
                  iconColor: Colors.black,
                  onPress: () {
                    Navigator.pop(context, 'OK');
                  })),
        ]));
  }
}

import 'dart:convert';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<List<String>> getCategoryImages() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');

  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final List<String> imagePaths = manifestMap.keys
      .where((String key) => key.contains('categories/'))
      .where((String key) => key.contains('.png'))
      .toList();

  return imagePaths;
}

class SelectCategoryImage extends StatefulWidget {
  SelectCategoryImage({
    Key? key,
    this.setSelectedImage,
    this.selectedImage,
    this.next,
  }) : super(key: key);

  final Function(String)? setSelectedImage;
  final String? selectedImage;
  final VoidCallback? next;

  @override
  _SelectCategoryImageState createState() => _SelectCategoryImageState();
}

class _SelectCategoryImageState extends State<SelectCategoryImage> {
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.selectedImage != null) {
      setState(() {
        selectedImage = widget.selectedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCategoryImages(),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          List<Widget> children = [];
          snapshot.data!.forEach((image) {
            children.add(ImageIcon(
              sizePadding: 8,
              margin: EdgeInsets.all(5),
              color: Colors.transparent,
              size: 55,
              iconPath: image,
              onTap: () {
                if (widget.setSelectedImage != null) {
                  widget.setSelectedImage!(image);
                  setState(() {
                    print(image);
                    selectedImage = image;
                  });
                  Future.delayed(Duration(milliseconds: 70), () {
                    Navigator.pop(context);
                    if (widget.next != null) {
                      widget.next!();
                    }
                  });
                }
              },
              outline: selectedImage == image,
            ));
          });
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: children,
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}

class ImageIcon extends StatelessWidget {
  ImageIcon({
    Key? key,
    required this.color,
    required this.size,
    this.onTap,
    this.margin,
    this.sizePadding = 20,
    this.outline = false,
    this.iconPath,
  }) : super(key: key);

  final Color color;
  final double size;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: margin ?? EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      height: size,
      width: size,
      decoration: outline
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.accentColorHeavy,
                width: 3,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            )
          : BoxDecoration(
              border: Border.all(
                color: color,
                width: 0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            ),
      child: Tappable(
        color: color,
        onTap: onTap,
        borderRadius: 500,
        child: Padding(
          padding: EdgeInsets.all(sizePadding),
          child: Image(
            image: AssetImage(iconPath ?? ""),
            width: size,
          ),
        ),
      ),
    );
  }
}

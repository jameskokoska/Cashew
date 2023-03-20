
import 'package:budget/colors.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/struct/iconObjects.dart';
import 'package:budget/widgets/textInput.dart';

import 'package:flutter/material.dart';

// Future<List<String>> getCategoryImages() async {
//   final manifestContent = await rootBundle.loadString('AssetManifest.json');

//   final Map<String, dynamic> manifestMap = json.decode(manifestContent);

//   final List<String> imagePaths = manifestMap.keys
//       .where((String key) => key.contains('categories/'))
//       .where((String key) => key.contains('.png'))
//       .toList();

//   return imagePaths;
// }

class SelectCategoryImage extends StatefulWidget {
  SelectCategoryImage({
    Key? key,
    required this.setSelectedImage,
    this.selectedImage,
    required this.setSelectedTitle,
    this.next,
  }) : super(key: key);

  final Function(String) setSelectedImage;
  final String? selectedImage;
  final Function(String?) setSelectedTitle;
  final VoidCallback? next;

  @override
  _SelectCategoryImageState createState() => _SelectCategoryImageState();
}

class _SelectCategoryImageState extends State<SelectCategoryImage> {
  String? selectedImage;
  String searchTerm = "";

  @override
  void initState() {
    super.initState();
    if (widget.selectedImage != null) {
      setState(() {
        selectedImage =
            widget.selectedImage!.replaceAll("assets/categories/", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          TextInput(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelText: "Search...",
            icon: Icons.search_rounded,
            onSubmitted: (value) {},
            onChanged: (value) {
              setState(() {
                searchTerm = value;
              });
              bottomSheetControllerGlobal.snapToExtent(0);
            },
            padding: EdgeInsets.all(0),
            autoFocus: true,
          ),
          SizedBox(height: 5),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: iconObjects.map((IconForCategory image) {
                bool show = false;
                if (searchTerm != "") {
                  for (int i = 0; i < image.tags.length; i++) {
                    if (image.tags[i].contains(searchTerm)) {
                      show = true;
                      break;
                    }
                  }
                } else {
                  show = true;
                }
                if (show)
                  return ImageIcon(
                    sizePadding: 8,
                    margin: EdgeInsets.all(5),
                    color: Colors.transparent,
                    size: 55,
                    iconPath: "assets/categories/" + image.icon,
                    onTap: () {
                      widget.setSelectedImage(image.icon);
                      widget.setSelectedTitle(image.mostLikelyCategoryName);
                      setState(() {
                        selectedImage = image.icon;
                      });
                      Future.delayed(Duration(milliseconds: 70), () {
                        Navigator.pop(context);
                        if (widget.next != null) {
                          widget.next!();
                        }
                      });
                    },
                    outline: selectedImage == image.icon,
                  );
                return SizedBox.shrink();
              }).toList(),
            ),
          ),
        ],
      ),
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

import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:example/util/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:sliding_sheet/sliding_sheet.dart';

// ignore_for_file: public_member_api_docs

const Color mapsBlue = Color(0xFF4185F3);

void main() => runApp(
      MaterialApp(
        title: 'Example App',
        debugShowCheckedModeBanner: false,
        home: Example(),
      ),
    );

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  static const textStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'sans-serif-medium',
    fontSize: 15,
  );

  SheetController controller = SheetController();

  bool tapped = false;
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          // Just some testing to ensure the sheet readjust
          // its snapped position when the constraints change.
          GestureDetector(
            onTap: () => setState(() => tapped = !tapped),
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: tapped ? 200 : 0,
              color: Colors.red,
            ),
          ),
          Expanded(
            child: buildSheet(),
          ),
        ],
      ),
    );
  }

  Widget buildSheet() {
    return SlidingSheet(
      duration: const Duration(milliseconds: 900),
      controller: controller,
      color: Colors.white,
      shadowColor: Colors.black26,
      elevation: 12,
      maxWidth: 500,
      cornerRadius: 16,
      cornerRadiusOnFullscreen: 0.0,
      closeOnBackdropTap: true,
      closeOnBackButtonPressed: true,
      addTopViewPaddingOnFullscreen: true,
      isBackdropInteractable: true,
      border: Border.all(
        color: Colors.grey.shade300,
        width: 3,
      ),
      snapSpec: SnapSpec(
        snap: true,
        positioning: SnapPositioning.relativeToAvailableSpace,
        snappings: const [
          SnapSpec.headerFooterSnap,
          0.6,
          SnapSpec.expanded,
        ],
        onSnap: (state, snap) {
          print('Snapped to $snap');
        },
      ),
      parallaxSpec: const ParallaxSpec(
        enabled: true,
        amount: 0.35,
        endExtent: 0.6,
      ),
      liftOnScrollHeaderElevation: 12.0,
      liftOnScrollFooterElevation: 12.0,
      body: _buildBody(),
      headerBuilder: buildHeader,
      footerBuilder: buildFooter,
      // builder: buildChild,
      customBuilder: buildInfiniteChild,
    );
  }

  Widget buildHeader(BuildContext context, SheetState state) {
    return CustomContainer(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shadowColor: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.topCenter,
            child: CustomContainer(
              width: 16,
              height: 4,
              borderRadius: 2,
              color:
                  Colors.grey.withOpacity(.5 * (1 - interval(0.7, 1.0, state.progress))),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                '5h 36m',
                style: textStyle.copyWith(
                  color: const Color(0xFFF0BA64),
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(353 mi)',
                style: textStyle.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fastest route now due to traffic conditions.',
            style: textStyle.copyWith(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildFooter(BuildContext context, SheetState state) {
    Widget button(
      Icon icon,
      Text text,
      VoidCallback onTap, {
      BorderSide border,
      Color color,
    }) {
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          const SizedBox(width: 8),
          text,
        ],
      );

      const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );

      return border == null
          ? ElevatedButton(
              onPressed: onTap,
              child: child,
              style: ElevatedButton.styleFrom(shape: shape),
            )
          : OutlinedButton(
              onPressed: onTap,
              child: child,
              style: OutlinedButton.styleFrom(shape: shape),
            );
    }

    return CustomContainer(
      shadowDirection: ShadowDirection.top,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Row(
        children: <Widget>[
          button(
            const Icon(
              Icons.navigation,
              color: Colors.white,
            ),
            Text(
              'Start',
              style: textStyle.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            () async {
              // Inherit from context...
              await SheetController.of(context).hide();
              Future.delayed(const Duration(milliseconds: 1500), () {
                // or use the controller
                controller.show();
              });
            },
            color: mapsBlue,
          ),
          const SizedBox(width: 8),
          SheetListenerBuilder(
            buildWhen: (oldState, newState) => oldState.isExpanded != newState.isExpanded,
            builder: (context, state) {
              final isExpanded = state.isExpanded;

              return button(
                Icon(
                  !isExpanded ? Icons.list : Icons.map,
                  color: mapsBlue,
                ),
                Text(
                  !isExpanded ? 'Steps & more' : 'Show map',
                  style: textStyle.copyWith(
                    fontSize: 15,
                  ),
                ),
                !isExpanded
                    ? () => controller.scrollTo(state.maxScrollExtent)
                    : controller.collapse,
                color: Colors.white,
                border: BorderSide(
                  color: Colors.grey.shade400,
                  width: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildInfiniteChild(
    BuildContext context,
    ScrollController controller,
    SheetState state,
  ) {
    return ListView.separated(
      controller: controller,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text('$index'),
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: 200,
    );
  }

  Widget buildChild(BuildContext context, SheetState state) {
    final divider = Container(
      height: 1,
      color: Colors.grey.shade300,
    );

    final titleStyle = textStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    const padding = EdgeInsets.symmetric(horizontal: 16);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        divider,
        const SizedBox(height: 32),
        InkWell(
          onTap: () => setState(() => show = !show),
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Traffic',
                  style: titleStyle,
                ),
                const SizedBox(height: 16),
                buildChart(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        divider,
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: padding,
              child: Text(
                'Steps',
                style: titleStyle,
              ),
            ),
            const SizedBox(height: 8),
            buildSteps(context),
          ],
        ),
        const SizedBox(height: 32),
        divider,
        const SizedBox(height: 32),
        Icon(
          MdiIcons.github,
          color: Colors.grey.shade900,
          size: 48,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: Text(
            'Pull request are welcome!',
            style: textStyle.copyWith(
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: Text(
            '(Stars too)',
            style: textStyle.copyWith(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget buildSteps(BuildContext context) {
    final steps = [
      Step('Go to your pubspec.yaml file.', '2 seconds'),
      Step(
          "Add the newest version of 'sliding_sheet' to your dependencies.", '5 seconds'),
      Step("Run 'flutter packages get' in the terminal.", '4 seconds'),
      Step("Happy coding!", 'Forever'),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, i) {
        final step = steps[i];

        return Padding(
          padding: const EdgeInsets.fromLTRB(56, 16, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                step.instruction,
                style: textStyle.copyWith(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text(
                    '${step.time}',
                    style: textStyle.copyWith(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget buildChart(BuildContext context) {
    final series = [
      charts.Series<Traffic, String>(
        id: 'traffic',
        data: [
          Traffic(0.5, '14:00'),
          Traffic(0.6, '14:30'),
          Traffic(0.5, '15:00'),
          Traffic(0.7, '15:30'),
          Traffic(0.8, '16:00'),
          Traffic(0.6, '16:30'),
        ],
        colorFn: (traffic, __) {
          if (traffic.time == '14:30') return charts.Color.fromHex(code: '#F0BA64');
          return charts.MaterialPalette.gray.shade300;
        },
        domainFn: (Traffic traffic, _) => traffic.time,
        measureFn: (Traffic traffic, _) => traffic.intesity,
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: show ? 256 : 128,
      color: Colors.transparent,
      child: charts.BarChart(
        series,
        animate: true,
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 12, // size in Pts.
              color: charts.MaterialPalette.gray.shade500,
            ),
          ),
        ),
        defaultRenderer: charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(5),
        ),
      ),
    );
  }

  Future<void> showBottomSheetDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final controller = SheetController();
    bool isDismissable = false;

    await showSlidingBottomSheet(
      context,
      // The parentBuilder can be used to wrap the sheet inside a parent.
      // This can be for example a Theme or an AnnotatedRegion.
      parentBuilder: (context, sheet) {
        return Theme(
          data: ThemeData.dark(),
          child: sheet,
        );
      },
      // The builder to build the dialog. Calling rebuilder on the dialogController
      // will call the builder, allowing react to state changes while the sheet is shown.
      builder: (context) {
        return SlidingSheetDialog(
          controller: controller,
          duration: const Duration(milliseconds: 500),
          snapSpec: const SnapSpec(
            snap: true,
            initialSnap: 0.7,
            snappings: [
              0.3,
              0.7,
            ],
          ),
          scrollSpec: const ScrollSpec(
            showScrollbar: true,
          ),
          color: Colors.teal,
          maxWidth: 500,
          minHeight: 700,
          isDismissable: isDismissable,
          dismissOnBackdropTap: true,
          isBackdropInteractable: true,
          onDismissPrevented: (backButton, backDrop) async {
            HapticFeedback.heavyImpact();

            if (backButton || backDrop) {
              const duration = Duration(milliseconds: 300);
              await controller.snapToExtent(0.2, duration: duration, clamp: false);
              await controller.snapToExtent(0.4, duration: duration);
              // or Navigator.pop(context);
            }

            // Or pop the route
            // if (backButton) {
            //   Navigator.pop(context);
            // }

            print('Dismiss prevented');
          },
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Confirm purchase',
                    style: textTheme.headline4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sagittis tellus lacus, et pulvinar orci eleifend in.',
                          style: textTheme.subtitle1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        isDismissable ? Icons.check : Icons.error,
                        color: Colors.white,
                        size: 56,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          footerBuilder: (context, state) {
            return Container(
              color: Colors.teal.shade700,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: textTheme.subtitle1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      if (!isDismissable) {
                        isDismissable = true;
                        SheetController.of(context).rebuild();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Approve',
                      style: textTheme.subtitle1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        buildMap(),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding:
                EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 16, 16, 0),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                await showBottomSheetDialog(context);
              },
              child: const Icon(
                Icons.layers,
                color: mapsBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMap() {
    return GestureDetector(
      onTap: () => setState(() => tapped = !tapped),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Image.asset(
              'assets/maps_screenshot.png',
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }
}

class Step {
  final String instruction;
  final String time;
  Step(
    this.instruction,
    this.time,
  );
}

class Traffic {
  final double intesity;
  final String time;
  Traffic(
    this.intesity,
    this.time,
  );
}

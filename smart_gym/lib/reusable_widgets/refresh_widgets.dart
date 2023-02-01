// using CustomRefreshIndicator example
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

const double defaultLoadingSpinnerSize = 20;

Widget loadingSpinner({
  EdgeInsets? padding,
  double? size,
}) {
  return Padding(
    padding: padding ?? EdgeInsets.zero,
    child: SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(
        value: null,
      ),
    ),
  );
}

AnimatedBuilder customRefreshIndicator(
    BuildContext context, Widget child, IndicatorController controller) {
  const double height = 150.0;
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final dy =
          controller.value.clamp(0.0, 1.25) * -(height - (height * 0.25));
      return Stack(
        children: [
          Transform.translate(
            offset: Offset(0.0, dy),
            child: child,
          ),
          Positioned(
            bottom: -height,
            left: 0,
            right: 0,
            height: height,
            child: Container(
              transform: Matrix4.translationValues(0.0, dy, 0.0),
              padding: const EdgeInsets.only(top: 30.0),
              constraints: const BoxConstraints.expand(),
              child: Column(
                children: [
                  if (controller.isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                    ),
                  Text(
                    controller.isLoading
                        ? "Refreshing..."
                        : "Pull to refresh workouts",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

// using CustomRefreshIndicator example
AnimatedBuilder customRefreshIndicatorLeading(
    BuildContext context, Widget child, IndicatorController controller) {
  const double height = 125.0;
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final dy = controller.value.clamp(0.0, 1.25) * (height - (height * 0.25));
      return Stack(
        children: [
          Transform.translate(
            offset: Offset(0.0, dy),
            child: child,
          ),
          Positioned(
            // bottom: height,
            top: -height,
            left: 0,
            right: 0,
            height: height,
            child: Container(
              transform: Matrix4.translationValues(0.0, dy, 0.0),
              padding: const EdgeInsets.only(top: 60.0),
              constraints: const BoxConstraints.expand(),
              child: Column(
                children: [
                  if (controller.isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                    ),
                  Text(
                    controller.isLoading
                        ? "Refreshing.."
                        : "Pull to refresh workouts",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

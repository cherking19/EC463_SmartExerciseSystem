import 'package:flutter/material.dart';
import '../../utils/widget_utils.dart';

class WeightTooltip extends StatelessWidget {
  final int weight;
  final bool enabled;

  const WeightTooltip({
    Key? key,
    required this.weight,
    required this.enabled,
  }) : super(key: key);

  String trimPlate(double plate) {
    int whole = plate.truncate();
    double remainder = plate - whole;

    if (remainder > 0) {
      return plate.toString();
    } else {
      String plateS = plate.toString();
      return plateS.substring(0, plateS.indexOf('.'));
    }
  }

  String printPlates(List<double> plates) {
    String config = '';

    for (double plate in plates) {
      config += '${trimPlate(plate)}, ';
    }

    return config.substring(0, config.length - 2);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          'Plates per side\n${printPlates(calculatePlates(weight.toDouble()))}',
      child: Text(
        weight.toString(),
      ),
    );
  }
}

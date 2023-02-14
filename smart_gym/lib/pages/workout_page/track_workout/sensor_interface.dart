import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:smart_gym/Screens/ble_settings.dart';
import 'package:smart_gym/services/sensor_service.dart';

class ProviderWidget extends StatefulWidget {
  const ProviderWidget({
    Key? key,
  }) : super(key: key);

  @override
  ProviderWidgetState createState() => ProviderWidgetState();
}

class ProviderWidgetState extends State<ProviderWidget> {
  void refresh() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    SensorService.of(context).addListener(refresh);
  }

  @override
  void dispose() {
    SensorService.of(context).removeListener(refresh);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('BASED ON PROVIDER DATA STRUCTURE'),
        SingleChildScrollView(
          child: Column(
            children: SensorService.of(context)
                .orientations
                .entries
                .map((orientationEntry) => Text(
                    '${orientationEntry.key}: \t ${orientationEntry.value.toString()}'))
                .toList(),
          ),
        ),
      ],
    );
  }
}

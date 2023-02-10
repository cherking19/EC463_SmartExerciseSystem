import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_gym/Screens/ble_settings.dart';

class DisplaySensorsPage extends StatelessWidget {
  const DisplaySensorsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => FlutterBlue.instance.startScan(
        timeout: const Duration(seconds: 4),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 2))
                  .asyncMap((event) => FlutterBlue.instance.connectedDevices),
              initialData: [],
              builder: (context, snapshot) {
                // filter out the non smart gym sensors
                final List<BluetoothDevice> smartGymSensors = snapshot.data!
                    .where((device) => isSmartGymSensor(device.name))
                    .toList();

                return Column(
                  children: smartGymSensors
                      .map(
                        (sensor) => ExpansionTile(
                          title: ListTile(
                            title: Text(sensor.name),
                            subtitle: Text(sensor.id.toString()),
                            trailing:
                                const Icon(Icons.circle, color: Colors.green),
                          ),
                          children: [
                            SmartGym_DeviceWidget(
                              device: sensor,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SmartGym_DeviceWidget extends StatefulWidget {
  final BluetoothDevice device;

  const SmartGym_DeviceWidget({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  SmartGym_DeviceWidgetState createState() => SmartGym_DeviceWidgetState();
}

class SmartGym_DeviceWidgetState extends State<SmartGym_DeviceWidget> {
  @override
  void initState() {
    super.initState();

    print('${widget.device} discovering');
    widget.device.discoverServices();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothService>>(
      stream: widget.device.services,
      initialData: const [],
      builder: (context, snapshot) {
        return SmartGym_ServiceWidget(
          service: snapshot.data!.first,
        );
      },
    );
  }
}

class SmartGym_ServiceWidget extends StatelessWidget {
  final BluetoothService service;

  const SmartGym_ServiceWidget({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext) {
    return Column(
      children: service.characteristics
          .map(
            (characteristic) => SmartGym_CharacteristicWidget(
              characteristic: characteristic,
            ),
          )
          .toList(),
    );
  }
}

class SmartGym_CharacteristicWidget extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const SmartGym_CharacteristicWidget({
    Key? key,
    required this.characteristic,
  }) : super(key: key);

  @override
  SmartGym_CharacteristicWidgetState createState() =>
      SmartGym_CharacteristicWidgetState();
}

class SmartGym_CharacteristicWidgetState
    extends State<SmartGym_CharacteristicWidget> {
  void startRead() async {
    print('${widget.characteristic} starting read');
    await widget.characteristic.setNotifyValue(true);
    await widget.characteristic.read();
  }

  @override
  void initState() {
    super.initState();

    startRead();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.characteristic.value,
      initialData: widget.characteristic.lastValue,
      builder: (context, snapshot) {
        final value = snapshot.data;
        Uint8List intBytes = Uint8List.fromList(value!.toList());
        List<double> floatList = intBytes.buffer.asFloat32List();

        return Text(
            floatList.isEmpty ? 'No Data' : floatList[0].toStringAsFixed(2));
      },
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:smart_gym/Screens/ble_settings.dart';
import 'package:smart_gym/services/sensor_service.dart';

class DisplaySensorsPage extends StatelessWidget {
  const DisplaySensorsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('ORIGINAL DEVICE SCREEN'),
        // SingleChildScrollView(
        //   child: Column(
        //     children: <Widget>[
        //       StreamBuilder<List<BluetoothDevice>>(
        //         stream: Stream.periodic(const Duration(seconds: 2))
        //             .asyncMap((event) => FlutterBlue.instance.connectedDevices),
        //         initialData: [],
        //         builder: (context, snapshot) {
        //           // filter out the non smart gym sensors
        //           final List<BluetoothDevice> smartGymSensors = snapshot.data!
        //               .where((device) => isSmartGymSensor(device.name))
        //               .toList();
        //           void initializeService(BluetoothService service) async {
        //             for (BluetoothCharacteristic characteristic
        //                 in service.characteristics) {
        //               await characteristic.setNotifyValue(true);
        //             }
        //           }

        //           for (BluetoothDevice device in smartGymSensors) {
        //             device.discoverServices();

        //             // result.then((value) {
        //             //   List<BluetoothService> services =
        //             //       value as List<BluetoothService>;
        //             //   for (BluetoothService service in services) {
        //             //     initializeService(service);
        //             //   }
        //             // });
        //           }

        //           return Column(
        //             children: smartGymSensors
        //                 .map((sensor) => Column(
        //                           children: [
        //                             Text(sensor.name),
        //                             SmartGym_DeviceWidget(
        //                               device: sensor,
        //                             ),
        //                           ],
        //                         )

        //                     // ExpansionTile(
        //                     //   title: ListTile(
        //                     //     title: Text(sensor.name),
        //                     //     subtitle: Text(sensor.id.toString()),
        //                     //     trailing:
        //                     //         const Icon(Icons.circle, color: Colors.green),
        //                     //   ),
        //                     //   children: [
        //                     //     SmartGym_DeviceWidget(
        //                     //       device: sensor,
        //                     //     ),
        //                     //   ],
        //                     // ),
        //                     )
        //                 .toList(),
        //           );
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        // ProviderWidget(),
      ],
    );
    // RefreshIndicator(
    //   onRefresh: () => FlutterBlue.instance.startScan(
    //     timeout: const Duration(seconds: 4),
    //   ),
    //   child:
    // );
  }
}

class ProviderWidget extends StatefulWidget {
  const ProviderWidget({
    Key? key,
  }) : super(key: key);

  @override
  ProviderWidgetState createState() => ProviderWidgetState();
}

class ProviderWidgetState extends State<ProviderWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    SensorService.of(context).addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // return AnimatedBuilder(
    //   animation: SensorService.of(context),
    //   builder: (context, child) {
    //     print('ANIMATING');
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
      //   );
      // },
    );
  }
}

class SensorProviderWidget extends StatelessWidget {
  final String name;
  final SensorOrientation orientation;

  const SensorProviderWidget({
    Key? key,
    required this.name,
    required this.orientation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('$name: \t ${orientation.toString()}');
  }
}

class SmartGym_DeviceWidget extends StatelessWidget {
  final BluetoothDevice device;

  const SmartGym_DeviceWidget({
    Key? key,
    required this.device,
  }) : super(key: key);

//   @override
//   SmartGym_DeviceWidgetState createState() => SmartGym_DeviceWidgetState();
// }

// class SmartGym_DeviceWidgetState extends State<SmartGym_DeviceWidget> {
  // @override
  // void initState() {
  //   super.initState();

  //   print('${widget.device} discovering');
  //   widget.device.discoverServices();
  // }

  void initializeCharacteristics(BluetoothService service) async {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      await characteristic.setNotifyValue(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothService>>(
      stream: device.services,
      initialData: const [],
      builder: (context, snapshot) {
        print('DATA ${snapshot.data!}');
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          BluetoothService sensorService = snapshot.data!.firstWhere(
            (service) =>
                service.uuid.toString().toUpperCase().substring(4, 8) == 'A123',
          );

          initializeCharacteristics(sensorService);

          return SmartGym_ServiceWidget(
            device: device,
            service: sensorService,
          );
        }

        return const Text('No Service');
      },
    );
  }
}

class SmartGym_ServiceWidget extends StatelessWidget {
  final BluetoothDevice device;
  final BluetoothService service;

  const SmartGym_ServiceWidget({
    Key? key,
    required this.device,
    required this.service,
  }) : super(key: key);

//   @override
//   SmartGym_ServiceWidgetState createState() => SmartGym_ServiceWidgetState();
// }

// class SmartGym_ServiceWidgetState extends State<SmartGym_ServiceWidget> {
//   bool initialized = false;

  // void initializeService() async {
  //   for (BluetoothCharacteristic characteristic
  //       in widget.service.characteristics) {
  //     await characteristic.setNotifyValue(true);
  //   }

  //   setState(() {
  //     initialized = true;
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();

  //   initializeService();
  // }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < service.characteristics.length; i++) {
      widgets.add(SmartGym_CharacteristicWidget(
        device: device,
        characteristic: service.characteristics[i],
        index: i,
      ));
    }

    return Column(
      children: widgets,
      // service.characteristics
      //     .map(
      //       (characteristic) => SmartGym_CharacteristicWidget(
      //         device: device,
      //         characteristic: characteristic,
      //       ),
      //     )
      //     .toList(),
    );
    // : const Text('Not initialized yet');
  }
}

class SmartGym_CharacteristicWidget extends StatelessWidget {
  final BluetoothDevice device;
  final BluetoothCharacteristic characteristic;
  final int index;

  const SmartGym_CharacteristicWidget({
    Key? key,
    required this.device,
    required this.characteristic,
    required this.index,
  }) : super(key: key);

//   @override
//   SmartGym_CharacteristicWidgetState createState() =>
//       SmartGym_CharacteristicWidgetState();
// }

// class SmartGym_CharacteristicWidgetState
//     extends State<SmartGym_CharacteristicWidget> {
//   void startRead() async {
//     print('${widget.characteristic} starting read');
//     await widget.characteristic.setNotifyValue(true);
//     // await widget.characteristic.read();
//   }

//   @override
//   void initState() {
//     super.initState();

//     startRead();
//   }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (context, snapshot) {
        final value = snapshot.data;
        Uint8List intBytes = Uint8List.fromList(value!.toList());
        List<double> floatList = intBytes.buffer.asFloat32List();

        if (floatList.isNotEmpty) {
          String sensorSuffix = device.name.split('_')[1];

          Map<String, SensorOrientation> orientations =
              SensorService.of(context).orientations;
          // Provider.of<SensorService>(context, listen: false).orientations;
          SensorOrientation orientation = orientations[sensorSuffix]!;

          String uuid =
              characteristic.uuid.toString().toUpperCase().substring(4, 8);

          if (uuid == '2A21') {
            orientation.yaw = floatList[0];
          } else if (uuid == '2A20') {
            orientation.pitch = floatList[0];
          } else if (uuid == '2A19') {
            orientation.roll = floatList[0];
          }

          // Provider.of<SensorService>(context, listen: false)
          //     .update(sensorSuffix, orientation);

          SensorService.of(context).update(sensorSuffix, orientation);
          // print(SensorService.of(context).toString());
        }

        // orientations.update(sensorSuffix, (value) => orientation);

        return Text(
            floatList.isEmpty ? 'No Data' : floatList[0].toStringAsFixed(2));
      },
    );
  }
}

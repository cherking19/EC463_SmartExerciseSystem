import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_gym/services/sensor_service.dart';
import '../reusable_widgets/ble_widgets.dart';

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  FindDevicesScreen({
    Key? key,
  }) : super(key: key) {
    FlutterBlue.instance.startScan(
      timeout: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBlue.instance.startScan(
          timeout: const Duration(seconds: 4),
        ),
        child: ListView(
          children: <Widget>[
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 2))
                  .asyncMap((_) => FlutterBlue.instance.connectedDevices),
              initialData: const [],
              builder: (c, snapshot) {
                return ExpansionTile(
                  title: const Text('Connected Devices'),
                  initiallyExpanded: snapshot.data!.isNotEmpty,
                  children: snapshot.data!.map(
                    (device) {
                      Stream<BluetoothDeviceState> deviceStateStream =
                          device.state.asBroadcastStream();

                      return ListTile(
                        title: Text(device.name),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: deviceStateStream,
                          initialData: BluetoothDeviceState.disconnecting,
                          builder: (innerContext, snapshot) {
                            void Function()? onPressed;
                            String text = 'Disconnecting';

                            if (snapshot.data! ==
                                BluetoothDeviceState.connected) {
                              text = 'Disconnect';
                              onPressed = () {
                                device.disconnect();
                              };
                            } else if (snapshot.data! ==
                                BluetoothDeviceState.disconnecting) {
                              text = 'Disconnecting';
                              onPressed = null;
                            }

                            return ElevatedButton(
                              onPressed: onPressed,
                              child: Text(text),
                            );
                          },
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: const [],
              builder: (c, snapshot) {
                final List<ScanResult> smartGymSensors = snapshot.data!.where(
                  (scanResult) {
                    return isSmartGymSensor(
                        scanResult.advertisementData.localName);
                  },
                ).toList();

                return ExpansionTile(
                  title: const Text('Bluetooth Search Results'),
                  initiallyExpanded: true,
                  children: smartGymSensors
                      .map(
                        (scanResult) => ScanResultTile(
                          scanResult: scanResult,
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

// class DeviceScreen extends StatelessWidget {
//   const DeviceScreen({
//     Key? key,
//     required this.device,
//   }) : super(key: key);

//   final BluetoothDevice device;

//   List<int> _getRandomBytes() {
//     final math = Random();
//     return [
//       math.nextInt(255),
//       math.nextInt(255),
//       math.nextInt(255),
//       math.nextInt(255)
//     ];
//   }

//   List<Widget> _buildServiceTiles(List<BluetoothService> services) {
//     return services
//         .map(
//           (s) => ServiceTile(
//             service: s,
//             characteristicTiles: s.characteristics
//                 .map(
//                   (c) => CharacteristicTile(
//                     characteristic: c,
//                     onReadPressed: () => c.read(),
//                     onWritePressed: () async {
//                       await c.write(_getRandomBytes(), withoutResponse: true);
//                       await c.read();
//                     },
//                     onNotificationPressed: () async {
//                       await c.setNotifyValue(!c.isNotifying);
//                       await c.read();
//                     },
//                     descriptorTiles: c.descriptors
//                         .map(
//                           (d) => DescriptorTile(
//                             descriptor: d,
//                             onReadPressed: () => d.read(),
//                             onWritePressed: () => d.write(_getRandomBytes()),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 )
//                 .toList(),
//           ),
//         )
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(device.name),
//         actions: <Widget>[
//           StreamBuilder<BluetoothDeviceState>(
//             stream: device.state,
//             initialData: BluetoothDeviceState.connecting,
//             builder: (c, snapshot) {
//               VoidCallback? onPressed;
//               String text;
//               switch (snapshot.data) {
//                 case BluetoothDeviceState.connected:
//                   onPressed = () => device.disconnect();
//                   text = 'DISCONNECT';
//                   break;
//                 case BluetoothDeviceState.disconnected:
//                   onPressed = () => device.connect();
//                   text = 'CONNECT';
//                   break;
//                 default:
//                   onPressed = null;
//                   text = snapshot.data.toString().substring(21).toUpperCase();
//                   break;
//               }
//               return TextButton(
//                   onPressed: onPressed,
//                   child: Text(
//                     text,
//                     style: Theme.of(context)
//                         .primaryTextTheme
//                         .button
//                         ?.copyWith(color: Colors.white),
//                   ));
//             },
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             StreamBuilder<BluetoothDeviceState>(
//               stream: device.state,
//               initialData: BluetoothDeviceState.connecting,
//               builder: (c, snapshot) => ListTile(
//                 leading: (snapshot.data == BluetoothDeviceState.connected)
//                     ? Icon(Icons.bluetooth_connected)
//                     : Icon(Icons.bluetooth_disabled),
//                 title: Text(
//                     'Device is ${snapshot.data.toString().split('.')[1]}.'),
//                 subtitle: Text('${device.id}'),
//                 trailing: StreamBuilder<bool>(
//                   stream: device.isDiscoveringServices,
//                   initialData: false,
//                   builder: (c, snapshot) => IndexedStack(
//                     index: snapshot.data! ? 1 : 0,
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.refresh),
//                         onPressed: () => device.discoverServices(),
//                       ),
//                       IconButton(
//                         icon: SizedBox(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation(Colors.grey),
//                           ),
//                           width: 18.0,
//                           height: 18.0,
//                         ),
//                         onPressed: null,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // StreamBuilder<int>(
//             //   stream: device.mtu,
//             //   initialData: 0,
//             //   builder: (c, snapshot) => ListTile(
//             //     title: Text('MTU Size'),
//             //     subtitle: Text('${snapshot.data} bytes'),
//             //     trailing: IconButton(
//             //       icon: Icon(Icons.edit),
//             //       onPressed: () => device.requestMtu(223),
//             //     ),
//             //   ),
//             // ),
//             // Image.asset(
//             //   'assets/dht22.png',
//             //   height: 150,
//             //   fit: BoxFit.cover,
//             // ),
//             StreamBuilder<List<BluetoothService>>(
//               stream: device.services,
//               initialData: [],
//               builder: (c, snapshot) {
//                 print('DATA: ${snapshot.data!}');
//                 return Column(
//                   children: _buildServiceTiles(snapshot.data!),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

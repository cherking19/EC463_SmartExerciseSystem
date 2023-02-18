import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_gym/services/sensor_service.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({
    Key? key,
    required this.scanResult,
    // this.onTap,
  }) : super(key: key);

  final ScanResult scanResult;
  // final VoidCallback? onTap;

  Widget _buildTitle(BuildContext context) {
    if (scanResult.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            scanResult.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            scanResult.device.id.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(scanResult.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    Stream<BluetoothDeviceState> deviceStateStream =
        scanResult.device.state.asBroadcastStream();

    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(scanResult.rssi.toString()),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: deviceStateStream,
        initialData: BluetoothDeviceState.disconnected,
        builder: (context, snapshot) {
          void Function()? onPressed;
          String text = 'Connect';

          if (snapshot.data! == BluetoothDeviceState.connected ||
              snapshot.data! == BluetoothDeviceState.disconnecting) {
            onPressed = null;
            text = 'Connected';
          } else if (snapshot.data! == BluetoothDeviceState.connecting) {
            onPressed = null;
            text = 'Connecting';
          }

          return ElevatedButton(
            onPressed: scanResult.advertisementData.connectable &&
                    snapshot.data! == BluetoothDeviceState.disconnected
                ? () async {
                    await SensorService.of(context).connectDevice(scanResult);
                  }
                : onPressed,
            child: Text(text),
          );
        },
      ),

      // color: Colors.black,
      // textColor: Colors.white,

      children: <Widget>[
        _buildAdvRow(context, 'Complete Local Name',
            scanResult.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${scanResult.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(
            context,
            'Manufacturer Data',
            getNiceManufacturerData(
                scanResult.advertisementData.manufacturerData)),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (scanResult.advertisementData.serviceUuids.isNotEmpty)
                ? scanResult.advertisementData.serviceUuids
                    .join(', ')
                    .toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(scanResult.advertisementData.serviceData)),
      ],
    );
  }
}

// class ServiceTile extends StatelessWidget {
//   final BluetoothService service;
//   final List<CharacteristicTile> characteristicTiles;

//   const ServiceTile(
//       {Key? key, required this.service, required this.characteristicTiles})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (service.uuid.toString().toUpperCase().substring(4, 8) == 'A123') {
//       return ExpansionTile(
//         title: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text('Service'),
//             Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
//                 style: Theme.of(context).textTheme.bodyText1?.copyWith(
//                     color: Theme.of(context).textTheme.caption?.color))
//           ],
//         ),
//         children: characteristicTiles,
//       );
//     } else {
//       return ListTile(
//         title: Text(''),
//       );
//     }
//   }
// }

// class CharacteristicTile extends StatelessWidget {
//   final BluetoothCharacteristic characteristic;
//   final List<DescriptorTile> descriptorTiles;
//   final VoidCallback? onReadPressed;
//   final VoidCallback? onWritePressed;
//   final VoidCallback? onNotificationPressed;

//   const CharacteristicTile(
//       {Key? key,
//       required this.characteristic,
//       required this.descriptorTiles,
//       this.onReadPressed,
//       this.onWritePressed,
//       this.onNotificationPressed})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<int>>(
//       stream: characteristic.value,
//       initialData: characteristic.lastValue,
//       builder: (c, snapshot) {
//         final value = snapshot.data;

//         Uint8List intBytes = Uint8List.fromList(value!.toList());
//         // You need the following statement for this StreamBuilder function to work.
//         // It seems that it requires to get a list from the buffer.
//         List<double> floatList = intBytes.buffer.asFloat32List();
//         // double currentVal = intBytes.buffer.asFloat32List().last;

//         return ExpansionTile(
//           title: ListTile(
//             title: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text((floatList.length == 0)
//                     ? "Refresh Please"
//                     : "${floatList[0].toStringAsFixed(2)}"),
//               ],
//             ),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(
//                   Icons.file_download,
//                   color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
//                 ),
//                 onPressed: onReadPressed,
//               ),
//               IconButton(
//                 icon: Icon(Icons.file_upload,
//                     color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
//                 onPressed: onWritePressed,
//               ),
//               IconButton(
//                 icon: Icon(
//                     characteristic.isNotifying
//                         ? Icons.sync_disabled
//                         : Icons.sync,
//                     color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
//                 onPressed: onNotificationPressed,
//               )
//             ],
//           ),
//           children: descriptorTiles,
//         );
//       },
//     );
//   }
// }

// class DescriptorTile extends StatelessWidget {
//   final BluetoothDescriptor descriptor;
//   final VoidCallback? onReadPressed;
//   final VoidCallback? onWritePressed;

//   const DescriptorTile(
//       {Key? key,
//       required this.descriptor,
//       this.onReadPressed,
//       this.onWritePressed})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text('Descriptor'),
//           Text('0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
//               style: Theme.of(context)
//                   .textTheme
//                   .bodyText1
//                   ?.copyWith(color: Theme.of(context).textTheme.caption?.color))
//         ],
//       ),
//       subtitle: StreamBuilder<List<int>>(
//         stream: descriptor.value,
//         initialData: descriptor.lastValue,
//         builder: (c, snapshot) => Text(snapshot.data.toString()),
//       ),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           IconButton(
//             icon: Icon(
//               Icons.file_download,
//               color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
//             ),
//             onPressed: onReadPressed,
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.file_upload,
//               color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
//             ),
//             onPressed: onWritePressed,
//           )
//         ],
//       ),
//     );
//   }
// }

// class AdapterStateTile extends StatelessWidget {
//   const AdapterStateTile({Key? key, required this.state}) : super(key: key);

//   final BluetoothState state;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.redAccent,
//       child: ListTile(
//         title: Text(
//           'Bluetooth adapter is ${state.toString().substring(15)}',
//           style: Theme.of(context).primaryTextTheme.subtitle1,
//         ),
//         trailing: Icon(
//           Icons.error,
//           color: Theme.of(context).primaryTextTheme.subtitle1?.color,
//         ),
//       ),
//     );
//   }
// }

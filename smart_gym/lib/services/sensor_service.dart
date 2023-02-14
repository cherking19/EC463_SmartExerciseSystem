import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_gym/Screens/ble_settings.dart';

const String rightShoulderSuffix = 'RightShoulder';
const String rightForearmSuffix = 'RightForearm';

const List<String> device_suffixes = [
  rightShoulderSuffix,
  rightForearmSuffix,
];

class SensorOrientation {
  double? yaw;
  double? pitch;
  double? roll;

  SensorOrientation();

  @override
  String toString() {
    return 'Yaw: ${yaw?.toStringAsFixed(2)} \t Pitch: ${pitch?.toStringAsFixed(2)} \t Roll: ${roll?.toStringAsFixed(2)}';
  }
}

class SensorService extends ChangeNotifier {
  Map<String, SensorOrientation> _orientations = HashMap();
  late Stream<List<BluetoothDevice>> deviceStream;
  late StreamSubscription deviceListener;
  List<StreamSubscription> characteristicListeners = [];
  List<Stream<List<int>>> characteristicStreams = [];

  Timer? timer;

  SensorService() {
    _orientations.addAll({
      rightShoulderSuffix: SensorOrientation(),
      rightForearmSuffix: SensorOrientation(),
    });

    initiateListening();

    timer = Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) async {
        await drainStreams();
        // initiateListening();
      },
    );
  }

  void initiateListening() {
    deviceStream = Stream.periodic(const Duration(seconds: 2))
        .asyncMap((event) => FlutterBlue.instance.connectedDevices)
        .asBroadcastStream();

    deviceStream.listen((sensors) async {
      final List<BluetoothDevice> smartGymSensors =
          sensors.where((device) => isSmartGymSensor(device.name)).toList();

      for (BluetoothDevice device in smartGymSensors) {
        List<BluetoothService> services = await device.discoverServices();

        BluetoothService sensorService = services.firstWhere(
          (service) =>
              service.uuid.toString().toUpperCase().substring(4, 8) == 'A123',
        );

        for (BluetoothCharacteristic characteristic
            in sensorService.characteristics) {
          await characteristic.setNotifyValue(true);
          Stream<List<int>> characteristicStream =
              characteristic.value.asBroadcastStream();

          characteristicStream.listen((data) {
            Uint8List intBytes = Uint8List.fromList(data.toList());
            List<double> floatList = intBytes.buffer.asFloat32List();

            if (floatList.isNotEmpty) {
              String sensorSuffix = device.name.split('_')[1];

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

              update(sensorSuffix, orientation);
            }
          });

          characteristicStreams.add(characteristicStream);
        }
      }
    });
  }

  Future<bool> drainStreams() async {
    for (Stream<List<int>> characteristicStream in characteristicStreams) {
      await characteristicStream.drain();
    }

    await deviceStream.drain();

    return true;
  }

  Map<String, SensorOrientation> get orientations {
    return _orientations;
  }

  void update(String sensorSuffix, SensorOrientation newOrientation) {
    _orientations.update(sensorSuffix, (value) => newOrientation);
    print(_orientations);
    notifyListeners();
  }

  @override
  String toString() {
    String string = '';

    for (MapEntry<String, SensorOrientation> entry in orientations.entries) {
      string = string + '${entry.key}: \t ${entry.value.toString()}\n';
    }

    return string;
  }

  static SensorService of(BuildContext context) {
    var provider =
        context.dependOnInheritedWidgetOfExactType<SensorServiceProvider>();
    return provider!.service;
  }
}

class SensorServiceProvider extends InheritedWidget {
  final SensorService service;

  const SensorServiceProvider({
    Key? key,
    required this.service,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SensorServiceProvider oldWidget) =>
      service != oldWidget.service;
}

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

const String rightShoulderSuffix = 'RightShoulder';
const String rightForearmSuffix = 'RightForearm';

const List<String> deviceSuffixes = [
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

const String sensorPrefix = 'SmartGymBros_';

bool isSmartGymSensor(String deviceName) {
  return deviceName.length >= sensorPrefix.length &&
      deviceName.substring(0, sensorPrefix.length) == sensorPrefix;
}

class SensorService extends ChangeNotifier {
  final Map<String, SensorOrientation> _orientations = HashMap();
  final Map<String, BluetoothCharacteristic> _hapticCharacteristics = HashMap();

  StreamController<Map<String, SensorOrientation>>
      orientationsStreamController =
      StreamController<Map<String, SensorOrientation>>.broadcast();

  SensorService() {
    _orientations.addAll({
      rightShoulderSuffix: SensorOrientation(),
      rightForearmSuffix: SensorOrientation(),
    });
    // _hapticCharacteristics.addAll({
    //   rightShoulderSuffix: BluetoothCharacteristic?,
    //   rightForearmSuffix: BluetoothCharacteristic()?,
    // }
    // )
  }

  // Connect to the sensor and begin listening to its data
  Future<void> connectDevice(ScanResult scanResult) async {
    BluetoothDevice device = scanResult.device;

    await device.connect();
    beginListening(scanResult);

    return;
  }

  // Listen to the bluetooth devices and store the orientation data in the map
  Future<void> beginListening(ScanResult scanResult) async {
    BluetoothDevice device = scanResult.device;

    List<BluetoothService> services = await device.discoverServices();
    BluetoothService sensorService = services.firstWhere(
      (service) =>
          service.uuid.toString().toUpperCase().substring(4, 8) == 'A123',
    );
      BluetoothService sensorServiceHaptic = services.firstWhere(
      (service) =>
          service.uuid.toString().toUpperCase().substring(4, 8) == 'A124',
    );
    for (BluetoothCharacteristic characteristic
        in sensorServiceHaptic.characteristics) {
          String sensorSuffix =
              scanResult.advertisementData.localName.split('_')[1];
            _hapticCharacteristics[sensorSuffix] =characteristic;

        }

    for (BluetoothCharacteristic characteristic
        in sensorService.characteristics) {
      await characteristic.setNotifyValue(true);
      Stream<List<int>> characteristicStream = characteristic.value;

      characteristicStream.listen((data) {
        Uint8List intBytes = Uint8List.fromList(data.toList());
        List<double> floatList = intBytes.buffer.asFloat32List();

        if (floatList.isNotEmpty) {
          String sensorSuffix =
              scanResult.advertisementData.localName.split('_')[1];

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
    }



  }

  Map<String, SensorOrientation> get orientations {
    return _orientations;
  }

    Map<String, BluetoothCharacteristic> get hapticCharacteristics {
    return _hapticCharacteristics;
  }

  void update(String sensorSuffix, SensorOrientation newOrientation) {
    _orientations.update(sensorSuffix, (value) => newOrientation);
    // print(_orientations);
    orientationsStreamController.add(_orientations);
    notifyListeners();
  }

  late Timer? mockTimer;
  int direction = 0; //0 going up, 1 going down

  void mockData() {
    SensorOrientation rightShoulderOrientation =
        orientations[rightShoulderSuffix]!;
    rightShoulderOrientation.pitch = 0;

    SensorOrientation rightForearmOrientation =
        orientations[rightForearmSuffix]!;
    rightForearmOrientation.pitch = 0;

    mockTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      mockIncrementData();
    });
  }

  void mockIncrementData() {
    SensorOrientation forearmOrientation = orientations[rightForearmSuffix]!;

    if (forearmOrientation.pitch! >= 80 && direction == 0) {
      direction = 1;
    } else if (forearmOrientation.pitch! <= 10 && direction == 1) {
      direction = 0;
    }

    if (direction == 0) {
      forearmOrientation.pitch = forearmOrientation.pitch! + 1.0;
    } else {
      forearmOrientation.pitch = forearmOrientation.pitch! - 1.0;
    }

    update(rightForearmSuffix, forearmOrientation);
  }

  @override
  String toString() {
    String string = '';

    for (MapEntry<String, SensorOrientation> entry in orientations.entries) {
      string = '$string${entry.key}: \t ${entry.value.toString()}\n';
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

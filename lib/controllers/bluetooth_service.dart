import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController {
  StreamSubscription<ScanResult>? _scanSubscription;
  final RxString _data = RxString('No data');

  String get data => _data.value;

  Future<void> startScanning() async {
    try {
      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scan().listen((scanResult) {
        if (scanResult.device.name == 'Your Arduino Device Name') {
          connectToDevice(scanResult.device);
        }
      });
    } catch (e) {
      print('Error scanning: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      await device.discoverServices();

      // device.servicesStream.listen((services) {
      //   for (var service in services) {
      //     if (service.uuid == Guid('your_service_uuid')) {
      //       for (BluetoothCharacteristic characteristic
      //           in service.characteristics) {
      //         if (characteristic.uuid ==
      //             Guid('your_characteristic_uuid')) {
      //           characteristic.setNotifyValue(true);
      //           characteristic.lastValueStream.listen((data) {
      //             final decodedData = String.fromCharCodes(data);
      //             _data.value = decodedData;
      //           });
      //         }
      //       }
      //     }
      //   }
      // });
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }
}

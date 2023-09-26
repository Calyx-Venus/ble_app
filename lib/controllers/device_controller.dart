import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class DeviceController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  String formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  //logic for connection/subscription to ble
  Stream<int> rssiStream(
      Duration frequency, BluetoothDevice device) async* {
    var isConnected = true;
    final subscription = device.connectionState.listen((v) {
      isConnected = v == BluetoothConnectionState.connected;
    });
    while (isConnected) {
      try {
        yield await device.readRssi();
      } catch (e) {
        print("Error reading RSSI: $e");
        break;
      }
      await Future.delayed(frequency);
    }
    // Device disconnected, stopping RSSI stream
    subscription.cancel();
  }

  List<int> _getRandomBytes() {
    //needed
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  String prettyException(String prefix, dynamic e) {
    if (e is FlutterBluePlusException) {
      return "$prefix ${e.errorString}";
    } else if (e is PlatformException) {
      return "$prefix ${e.message}";
    }
    return e.toString();
  }
}

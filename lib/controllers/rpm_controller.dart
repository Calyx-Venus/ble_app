import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class RpmController extends GetxController {
  late final BluetoothDevice device;
  final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();
  // RpmController();
  BluetoothCharacteristic? c;
  @override
  void onReady() {
    startRun(c!);
    super.onInit();
  }

  void startRun(BluetoothCharacteristic c) async {
    try {
      c.onValueReceived.listen((value) {
        debugPrint(value.toString()); //subscribe to arduino
      });

      await c.setNotifyValue(!c.isNotifying);
      if (c.properties.read) {
        var strm = await c.read();
        print("stream is workinngggggg:$strm");
      }
    } catch (e) {
      final snackBar = SnackBar(
          content: Text(prettyException("Subscribe Error:", e)));
      snackBarKeyC.currentState?.showSnackBar(snackBar);
    }
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

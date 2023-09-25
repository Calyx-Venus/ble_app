import 'dart:math';
import 'package:ble_app/views/pages/rpm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'characteristic_tile.dart';
import 'descriptor_tile.dart';
import 'service_tile.dart';

class ServiceList extends StatelessWidget {
  ServiceList({super.key, required this.services, required this.d});

  final List<BluetoothService> services;
  final BluetoothDevice d;
  final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: services
            .map(
              (s) => ServiceTile(
                service: s,
                characteristicTiles: s.characteristics
                    .map(
                      (c) => CharacteristicTile(
                        characteristic: c,
                        //onRead Pressed //pulling from the arduino
                        onReadPressed: () async {
                          try {
                            while (true) {
                              List<int> data = await c
                                  .read(); //list of ints coming in (bytes)
                              print('incoming//////');
                              var gap = data[0];
                              print('gap $gap');
                            }
                          } catch (e) {
                            final snackBar = SnackBar(
                                content: Text(prettyException(
                                    "Read Error:", e)));
                            snackBarKeyC.currentState?.showSnackBar(
                                snackBar); //for debugging purposes
                          }
                        },
                        //on Write Pressed 1 //sends number [3] which gives blue light
                        onWritePressed: () async {
                          try {
                            await c.write([3],
                                withoutResponse: false); //blue
                            if (c.properties.read) {
                              await c.read();
                              // print('blue/////////');
                              print(await c.read);
                            }
                          } catch (e) {
                            final snackBar = SnackBar(
                                content: Text(prettyException(
                                    "Write Error:", e)));
                            snackBarKeyC.currentState
                                ?.showSnackBar(snackBar);
                          }
                        },
                        //on Write Pressed 2 //sends number [2] which gives green light
                        onWritePressedTwo: () async {
                          try {
                            await c.write([2],
                                withoutResponse: false); //green
                            if (c.properties.read) {
                              await c.read();
                              print('green/////////');
                              print(await c.read);
                            }
                          } catch (e) {
                            final snackBar = SnackBar(
                                content: Text(prettyException(
                                    "Write Error", e)));
                            snackBarKeyC.currentState
                                ?.showSnackBar(snackBar);
                          }
                        },
                        //on write pressed red //sends number 1 for red
                        onWritePressedRed: () async {
                          try {
                            await c.write([1],
                                withoutResponse: false); //red
                            if (c.properties.read) {
                              await c.read();
                              print('red//////////');
                              print(await c.read);
                            }
                          } catch (e) {
                            final snackBar = SnackBar(
                                content: Text(prettyException(
                                    "Write Error", e)));
                            snackBarKeyC.currentState
                                ?.showSnackBar(snackBar);
                          }
                        },

                        onNotificationPressed: () {
                          Get.to(
                              () => RpmPage(
                                    c: c,
                                  ),
                              arguments: d);
                        },

                        //descriptor tiles
                        descriptorTiles: c.descriptors
                            .map(
                              (d) => DescriptorTile(
                                descriptor: d,
                                onReadPressed: () async {
                                  try {
                                    await d.read();
                                  } catch (e) {
                                    final snackBar = SnackBar(
                                        content: Text(prettyException(
                                            "Read Error:", e)));
                                    snackBarKeyC.currentState
                                        ?.showSnackBar(snackBar);
                                  }
                                },
                                onWritePressed: () async {
                                  try {
                                    await d.write(_getRandomBytes());
                                  } catch (e) {
                                    final snackBar = SnackBar(
                                        content: Text(prettyException(
                                            "Write Error:", e)));
                                    snackBarKeyC.currentState
                                        ?.showSnackBar(snackBar);
                                  }
                                },
                              ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList());
  }
}

String prettyException(String prefix, dynamic e) {
  if (e is FlutterBluePlusException) {
    return "$prefix ${e.errorString}";
  } else if (e is PlatformException) {
    return "$prefix ${e.message}";
  }
  return e.toString();
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

import 'dart:async';
import 'dart:math';
import 'package:ble_app/views/components/service_list.dart';
import 'package:get/state_manager.dart';
import 'package:get/get.dart';
import 'rpm.dart';
import 'package:ble_app/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  void initState() {
    super.initState();
  }

  final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

//connect or disconnect from bluetooth based on case
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.localName),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: widget.device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothConnectionState.connected:
                    onPressed = () async {
                      try {
                        await widget.device.disconnect();
                      } catch (e) {
                        final snackBar = SnackBar(
                            content:
                                Text(prettyException("Disconnect Error:", e)));
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      }
                    };
                    text = 'DISCONNECT';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      try {
                        await widget.device.connect();
                      } catch (e) {
                        final snackBar = SnackBar(
                            content:
                                Text(prettyException("Connect Error:", e)));
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      }
                    };
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text =
                        snapshot.data.toString().split(".").last.toUpperCase();
                    break;
                }
                return TextButton(
                    onPressed: onPressed,
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelLarge
                          ?.copyWith(color: Colors.white),
                    ));
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<BluetoothConnectionState>(
                stream: widget.device.connectionState,
                initialData: BluetoothConnectionState.connecting,
                builder: (c, snapshot) => ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      snapshot.data == BluetoothConnectionState.connected
                          ? const Icon(Icons.bluetooth_connected)
                          : const Icon(Icons.bluetooth_disabled),
                      snapshot.data == BluetoothConnectionState.connected
                          ? StreamBuilder<int>(
                              stream: rssiStream(),
                              builder: (context, snapshot) {
                                return Text(
                                    snapshot.hasData
                                        ? '' //'${snapshot.data}dBm'
                                        : '',
                                    style:
                                        Theme.of(context).textTheme.bodySmall);
                              })
                          : Text('',
                              style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  title: Text(
                      'Device is ${snapshot.data.toString().split('.')[1]}.'), //this says "device is connected"
                  subtitle: Text(''), //Text('${widget.device.remoteId}'),
                  trailing: StreamBuilder<bool>(
                    stream: widget.device.isDiscoveringServices,
                    initialData: false,
                    builder: (c, snapshot) => IndexedStack(
                      index: snapshot.data! ? 1 : 0,
                      children: <Widget>[
                        TextButton(
                          child: const Text(
                              "Initialize for Run"), //discover services
                          onPressed: () async {
                            try {
                              await widget.device.discoverServices();
                            } catch (e) {
                              final snackBar = SnackBar(
                                  content: Text(prettyException(
                                      "Discover Services Error:", e)));
                              snackBarKeyC.currentState?.showSnackBar(snackBar);
                            }
                          },
                        ),
                        const IconButton(
                          icon: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                            ),
                            width: 18.0,
                            height: 18.0,
                          ),
                          onPressed: null,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder<int>(
                stream: widget.device.mtu,
                initialData: 0,
                builder: (c, snapshot) => ListTile(
                  title: Text(''), //Text('MTU Size'),
                  subtitle: Text(''), //Text('${snapshot.data} bytes'),
                  // trailing: IconButton(
                  //     icon: const Icon(Icons.edit),
                  //     onPressed: () async {
                  //       try {
                  //         await device.requestMtu(223);
                  //       } catch (e) {
                  //         final snackBar = SnackBar(content: Text(prettyException("Change Mtu Error:", e)));
                  //         snackBarKeyC.currentState?.showSnackBar(snackBar);
                  //       }
                  //     }),
                ),
              ),
              StreamBuilder<List<BluetoothService>>(
                stream: widget.device.services,
                initialData: const [],
                builder: (c, snapshot) {
                  return ServiceList(
                      services: snapshot.data! as List<BluetoothService>);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

//logic for connection/subscription to ble
  Stream<int> rssiStream(
      {Duration frequency = const Duration(seconds: 1)}) async* {
    var isConnected = true;
    final subscription = widget.device.connectionState.listen((v) {
      isConnected = v == BluetoothConnectionState.connected;
    });
    while (isConnected) {
      try {
        yield await widget.device.readRssi();
      } catch (e) {
        print("Error reading RSSI: $e");
        break;
      }
      await Future.delayed(frequency);
    }
    // Device disconnected, stopping RSSI stream
    subscription.cancel();
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

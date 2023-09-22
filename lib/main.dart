import 'dart:async';
import 'dart:io';
import 'package:ble_app/views/pages/device_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets.dart';

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const FlutterBlueApp());
    });
  } else {
    runApp(const FlutterBlueApp());
  }
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: StreamBuilder<BluetoothAdapterState>(
          stream: FlutterBluePlus.adapterState,
          initialData: BluetoothAdapterState.unknown,
          builder: (c, snapshot) {
            final adapterState = snapshot.data;
            if (adapterState == BluetoothAdapterState.on) {
              return const FindDevicesScreen();
            }
            return BluetoothOffScreen(adapterState: adapterState);
          }),
    );
  }
}

///if bluetoothAdapterState.off
class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyA,
      child: Scaffold(
        //backgroundColor: Colors.black12,
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
                'Bluetooth Adapter is ${adapterState != null ? adapterState.toString().split(".").last : 'not available'}.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleSmall
                    ?.copyWith(color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text('TURN ON'),
                onPressed: () async {
                  try {
                    if (Platform.isAndroid) {
                      await FlutterBluePlus.turnOn();
                    }
                  } catch (e) {
                    final snackBar = SnackBar(
                        content: Text(prettyException("Error Turning On:", e)));
                    snackBarKeyA.currentState?.showSnackBar(snackBar);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//if BluetoothAdapterState.on
//screen defining UI for landing page search
class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: snackBarKeyB,
      child: Scaffold(
        //backgroundColor: Colors.black12,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black12,
          foregroundColor: Colors.amber[50],
          title: const Text('Neptronxs'),
        ),
        body: RefreshIndicator(
          onRefresh: () => FlutterBluePlus.startScan(
              timeout: const Duration(seconds: 15),
              androidUsesFineLocation: true),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  StreamBuilder<List<BluetoothDevice>>(
                    stream: Stream.periodic(const Duration(seconds: 2))
                        .asyncMap((_) => FlutterBluePlus.connectedDevices),
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map((d) => ListTile(
                                title: Text(d.localName),
                                subtitle: Text(d.remoteId.toString()),
                                trailing:
                                    StreamBuilder<BluetoothConnectionState>(
                                  stream: d.connectionState,
                                  initialData:
                                      BluetoothConnectionState.disconnected,
                                  builder: (c, snapshot) {
                                    if (snapshot.data ==
                                        BluetoothConnectionState.connected) {
                                      return ElevatedButton(
                                        child: const Text('OPEN'),
                                        onPressed: () => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    DeviceScreen(device: d))),
                                      );
                                    }
                                    return Text(snapshot.data.toString());
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  StreamBuilder<List<ScanResult>>(
                    stream: FlutterBluePlus.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map(
                            (r) => ScanResultTile(
                              result: r,
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                r.device.connect().catchError((e) {
                                  final snackBar = SnackBar(
                                      content: Text(prettyException(
                                          "Connect Error:", e)));
                                  snackBarKeyB.currentState
                                      ?.showSnackBar(snackBar);
                                });
                                return DeviceScreen(device: r.device);
                              })),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //stop scan section///
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBluePlus.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () async {
                  try {
                    FlutterBluePlus.stopScan();
                  } catch (e) {
                    final snackBar = SnackBar(
                        content: Text(prettyException("Stop Scan Error:", e)));
                    snackBarKeyB.currentState?.showSnackBar(snackBar);
                  }
                  ;
                },
                backgroundColor: Colors.red,
              );
            } else {
              //this section defines the landing page - search
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/minidyno.jpeg'),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Search for BlueTooth Device',
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                        icon: Icon(Icons.search),
                        iconSize: 100,
                        color: Colors.amber[400],
                        onPressed: () async {
                          try {
                            FlutterBluePlus.startScan(
                                timeout: const Duration(seconds: 15),
                                androidUsesFineLocation: false);
                          } catch (e) {
                            final snackBar = SnackBar(
                                content: Text(
                                    prettyException("Start Scan Error:", e)));
                            snackBarKeyB.currentState?.showSnackBar(snackBar);
                          }
                        }),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

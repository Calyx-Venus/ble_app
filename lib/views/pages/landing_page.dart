//screen defining UI for landing page search
import 'package:ble_app/views/components/service_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../../widgets.dart';
import 'device_screen.dart';

final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();

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
                    stream:
                        Stream.periodic(const Duration(seconds: 2))
                            .asyncMap((_) =>
                                FlutterBluePlus.connectedDevices),
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map((d) => ListTile(
                                title: Text(d.localName),
                                subtitle: Text(d.remoteId.toString()),
                                trailing: StreamBuilder<
                                    BluetoothConnectionState>(
                                  stream: d.connectionState,
                                  initialData:
                                      BluetoothConnectionState
                                          .disconnected,
                                  builder: (c, snapshot) {
                                    if (snapshot.data ==
                                        BluetoothConnectionState
                                            .connected) {
                                      return ElevatedButton(
                                          child: const Text('OPEN'),
                                          onPressed: () => Get.to(
                                              () => DeviceScreen(),
                                              arguments: d));
                                    }
                                    return Text(
                                        snapshot.data.toString());
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
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) {
                                r.device.connect().catchError((e) {
                                  final snackBar = SnackBar(
                                      content: Text(prettyException(
                                          "Connect Error:", e)));
                                  snackBarKeyB.currentState
                                      ?.showSnackBar(snackBar);
                                });
                                //! might need to pass device here in the future
                                return DeviceScreen();
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
                        content: Text(
                            prettyException("Stop Scan Error:", e)));
                    snackBarKeyB.currentState?.showSnackBar(snackBar);
                  }
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
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Search for BlueTooth Device',
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                        icon: const Icon(Icons.search),
                        iconSize: 100,
                        color: Colors.amber[400],
                        onPressed: () async {
                          try {
                            FlutterBluePlus.startScan(
                                timeout: const Duration(seconds: 15),
                                androidUsesFineLocation: false);
                          } catch (e) {
                            final snackBar = SnackBar(
                                content: Text(prettyException(
                                    "Start Scan Error:", e)));
                            snackBarKeyB.currentState
                                ?.showSnackBar(snackBar);
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

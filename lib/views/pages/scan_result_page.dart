import 'package:ble_app/controllers/bluetooth_service.dart';
import 'package:ble_app/customfullscreendialog.dart';
import 'package:ble_app/main.dart';
import 'package:ble_app/views/components/service_list.dart';
import 'package:ble_app/views/pages/device_screen.dart';
import 'package:ble_app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class ScanResultsPage extends StatelessWidget {
  const ScanResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
      ),
      // check if scanning for devices
      body: StreamBuilder<bool>(
        stream: FlutterBluePlus.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          bool scanning = snapshot.data!;
          //if scanning then show the results
          if (scanning) {
            return SingleChildScrollView(
                child: Column(
              children: [
                //here we show connected devices.
                StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 2))
                      .asyncMap((_) =>
                          FlutterBluePlus.connectedSystemDevices),
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.localName),
                              subtitle: Text(d.remoteId.toString()),
                              trailing: StreamBuilder<
                                  BluetoothConnectionState>(
                                stream: d.connectionState,
                                initialData: BluetoothConnectionState
                                    .disconnected,
                                builder: (c, snapshot) {
                                  if (snapshot.data ==
                                      BluetoothConnectionState
                                          .connected) {
                                    return ElevatedButton(
                                        child: const Text('OPEN'),
                                        onPressed: () {
                                          print(
                                              'this is the deviceeeeeeeee: $d');
                                        });
                                  }
                                  return Text(
                                      snapshot.data.toString());
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
                //here we show scan results
                StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map(
                          (r) => ScanResultTile(
                              result: r,
                              onTap: () async {
                                BluetoothController blc =
                                    BluetoothController();
                                CustomFullScreenDialog.showDialog();
                                await blc
                                    .connectToDevice(r.device)
                                    .then((value) {
                                  CustomFullScreenDialog
                                      .cancelDialog();
                                  Get.to(DeviceScreen(d: r.device));
                                }).catchError((e) {
                                  print(e);
                                  CustomFullScreenDialog
                                      .cancelDialog();
                                });
                              }),
                        )
                        .toList(),
                  ),
                ),
              ],
            ));
            //if not scanning show scanning page
          } else {
            //this section defines the landing page - search
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            content: Text(
                              prettyException("Start Scan Error:", e),
                            ),
                          );
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
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
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
              child: const Icon(Icons.stop),
            );
          } else {
            //this section defines the landing page - search
            return SizedBox();
          }
        },
      ),
    );
  }
}

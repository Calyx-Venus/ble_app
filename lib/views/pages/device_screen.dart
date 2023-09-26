import 'package:ble_app/controllers/device_controller.dart';
import 'package:ble_app/views/components/service_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class DeviceScreen extends StatelessWidget {
  DeviceScreen({super.key, required this.d});
  final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();
  //this initializes the controller
  final controller = Get.put(DeviceController());

  final BluetoothDevice d;
  @override
  Widget build(BuildContext context) {
    // controller.device = Get.arguments as BluetoothDevice;

    return ScaffoldMessenger(
      key: snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(d.localName),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: d.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (context, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothConnectionState.connected:
                    onPressed = () async {
                      try {
                        await d.disconnect();
                      } catch (e) {
                        final snackBar = SnackBar(
                            content: Text(prettyException(
                                "Disconnect Error:", e)));
                        snackBarKeyC.currentState
                            ?.showSnackBar(snackBar);
                      }
                    };
                    text = 'DISCONNECT';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      try {
                        await d.connect();
                      } catch (e) {
                        final snackBar = SnackBar(
                          content: Text(
                            prettyException("Connect Error:", e),
                          ),
                        );
                        snackBarKeyC.currentState
                            ?.showSnackBar(snackBar);
                      }
                    };
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data
                        .toString()
                        .split(".")
                        .last
                        .toUpperCase();
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
                stream: d.connectionState,
                initialData: BluetoothConnectionState.connecting,
                builder: (context, snapshot) => ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      snapshot.data ==
                              BluetoothConnectionState.connected
                          ? const Icon(Icons.bluetooth_connected)
                          : const Icon(Icons.bluetooth_disabled),
                      snapshot.data ==
                              BluetoothConnectionState.connected
                          ? StreamBuilder<int>(
                              stream: controller.rssiStream(
                                  const Duration(seconds: 1), d),
                              builder: (context, snapshot) {
                                return Text(
                                    snapshot.hasData
                                        ? '' //'${snapshot.data}dBm'
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall);
                              })
                          : Text('',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall),
                    ],
                  ),
                  title: Text(
                      'Device is ${snapshot.data.toString().split('.')[1]}.'), //this says "device is connected"
                  subtitle: const Text(
                      ''), //Text('${controller.device.remoteId}'),
                  trailing: StreamBuilder<bool>(
                    stream: d.isDiscoveringServices,
                    initialData: false,
                    builder: (c, snapshot) => IndexedStack(
                      index: snapshot.data! ? 1 : 0,
                      children: <Widget>[
                        TextButton(
                          child: const Text(
                              "Initialize for Run"), //discover services
                          onPressed: () async {
                            try {
                              await d.discoverServices();
                            } catch (e) {
                              final snackBar = SnackBar(
                                  content: Text(prettyException(
                                      "Discover Services Error:",
                                      e)));
                              snackBarKeyC.currentState
                                  ?.showSnackBar(snackBar);
                            }
                          },
                        ),
                        const IconButton(
                          icon: SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.grey),
                            ),
                          ),
                          onPressed: null,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              StreamBuilder<int>(
                stream: d.mtu,
                initialData: 0,
                builder: (con, snapshot) => const ListTile(
                  title: Text(''), //Text('MTU Size'),
                  subtitle:
                      Text(''), //Text('${snapshot.data} bytes'),
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
                stream: d.servicesStream,
                initialData: const [],
                builder: (c, snapshot) {
                  return ServiceList(d: d, services: snapshot.data!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

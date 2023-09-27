import 'package:ble_app/views/components/service_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RpmPage extends StatefulWidget {
  RpmPage({super.key, required this.c, required this.device});
  final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

  final BluetoothCharacteristic c;
  final BluetoothDevice device;
  // final controller = Get.put(RpmController());
  @override
  State<RpmPage> createState() => _RpmPageState();
}

class _RpmPageState extends State<RpmPage> {
  @override
  void initState() async {
    super.initState();
    initializePage();
  }

  Future<void> initializePage() async {
    try {
      await startRun(widget.c);
    } catch (e) {
      final snackBar = SnackBar(
          content: Text(prettyException("Initialization Error:", e)));
      widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<List<BluetoothService>>(
            stream: widget.device.servicesStream,
            initialData: const [],
            builder: (context, snapshot) {
              List<BluetoothService> bluetoothServices =
                  snapshot.data!;
              return ServiceList(
                services: bluetoothServices,
                d: widget.device,
              );
            },
          ),
          const Text('RPM',
              style: TextStyle(fontSize: 30, color: Colors.amber)),
          const Text(
            'Placeholder',
            style: TextStyle(fontSize: 30, color: Colors.amber),
          )
        ],
      ),
    );
  }

  Future<void> startRun(BluetoothCharacteristic c) async {
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
      widget.snackBarKeyC.currentState?.showSnackBar(snackBar);
    }
  }
}

// class RpmPage extends stateful {
//   RpmPage({super.key, required this.c, required this.device});
//   final BluetoothCharacteristic c;
//   final BluetoothDevice device;
//   final controller = Get.put(RpmController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black54,
//       body: FutureBuilder(
//           future: controller.startRun(c),
//           builder: (context, snapshot) {
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 StreamBuilder<List<BluetoothService>>(
//                   stream: device.servicesStream,
//                   initialData: const [],
//                   builder: (context, snapshot) {
//                     List<BluetoothService> bluetoothServices =
//                         snapshot.data!;
//                     return ServiceList(
//                       services: bluetoothServices,
//                       d: device,
//                     );
//                   },
//                 ),
//                 const Text('RPM',
//                     style:
//                         TextStyle(fontSize: 30, color: Colors.amber)),
//                 const Text(
//                   'Placeholder',
//                   style: TextStyle(fontSize: 30, color: Colors.amber),
//                 )
//               ],
//             );
//           }),
//     );
//   }
// }


// class RpmPage extends StatefulWidget {
//   const RpmPage({super.key, required this.device});
  
  

//   @override
//   State<RpmPage> createState() => _RpmPageState();

//   //want StartRun to trigger when user gets to rpm page
// }

// class _RpmPageState extends State<RpmPage> {
//   dynamic value = [0];
//   final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

//   @override
//   //need this section to always update
//   Widget build(BuildContext context) {
    
//   }
// }



//stateful widget and state.setstate
// void StartRun () async {
//                       try {
//                         c.onValueReceived.listen((value) {
//                           print(value);
//                         });

//                         await c.setNotifyValue(!c.isNotifying);
//                         if (c.properties.read) {
//                           var strm = await c.read();
//                           Get.to(() => RpmPage());
//                         }
//                       } catch (e) {
//                         final snackBar = SnackBar(
//                             content:
//                                 Text(prettyException("Subscribe Error:", e)));
//                         snackBarKeyC.currentState?.showSnackBar(snackBar);
//                       }
//                     };

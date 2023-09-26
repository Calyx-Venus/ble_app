import 'package:ble_app/controllers/rpm_controller.dart';
import 'package:ble_app/views/components/service_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class RpmPage extends StatelessWidget {
  RpmPage({super.key, required this.c});
  final BluetoothCharacteristic c;
  final controller = Get.put(RpmController());

  @override
  Widget build(BuildContext context) {
    controller.device = Get.arguments as BluetoothDevice;
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<List<BluetoothService>>(
            stream: controller.device.servicesStream,
            initialData: const [],
            builder: (context, snapshot) {
              List<BluetoothService> bluetoothServices = snapshot.data!;
              return ServiceList(
                services: bluetoothServices,
                d: controller.device,
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
}


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

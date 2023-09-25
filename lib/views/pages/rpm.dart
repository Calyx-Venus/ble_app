import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class RpmPage extends StatefulWidget {
  const RpmPage({super.key, required this.device});

  final BluetoothDevice device; 
  
  @override
  State<RpmPage> createState() => _RpmPageState();

  
 //want StartRun to trigger when user gets to rpm page 
   
}

class _RpmPageState extends State<RpmPage> {

dynamic value = [0];
 final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

@override
  void initState() { 
    StartRun();
    super.initState(); 
  }
   void StartRun () async {
                      try {
                        c.onValueReceived.listen((value) {
                          print(value); //subscribe to arduino 
                        });

                        await c.setNotifyValue(!c.isNotifying);
                        if (c.properties.read) {
                          var strm = await c.read();
                        }
                      } catch (e) {
                        final snackBar = SnackBar(
                            content:
                                Text(prettyException("Subscribe Error:", e)));
                        snackBarKeyC.currentState?.showSnackBar(snackBar);
                      } 
                    },

  @override
  //need this section to always update 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           StreamBuilder<List<BluetoothService>>(
                stream: widget.device.services,
                initialData: const [],
                builder: (c, snapshot) {
                  return Column(
                    //children: _buildServiceTiles(context, snapshot.data!),
                  );
                },
              ),
          Text('RPM $value', style: TextStyle(fontSize: 30, color: Colors.amber)),
          Text(
            'Placeholder',
            style: TextStyle(fontSize: 30, color: Colors.amber),
          ),
        ],
      ),
    );
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
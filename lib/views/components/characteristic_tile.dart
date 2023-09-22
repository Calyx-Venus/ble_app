import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'descriptor_tile.dart';

class CharacteristicTile extends StatefulWidget {
  //chracteristic class///////////
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onWritePressedTwo; //changed
  final VoidCallback? onWritePressedRed; //changed
  final VoidCallback? onNotificationPressed;

  const CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
      this.onReadPressed,
      this.onWritePressed,
      this.onWritePressedTwo, //changed
      this.onWritePressedRed, //changed
      this.onNotificationPressed})
      : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  @override
  //this part has UI for the characteristics//////characteristicUuid
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: widget.characteristic.onValueReceived,
      initialData: widget.characteristic.lastValue,
      builder: (context, snapshot) {
        final List<int>? value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Characteristic'),
                      Text('--',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color))
                    ],
                  ),
                ),
                //first UI section with buttons
                if (widget.characteristic.properties.read) //if there's a read
                  IconButton(
                      icon: Icon(
                        Icons.file_download,
                        color:
                            Theme.of(context).iconTheme.color?.withOpacity(0.5),
                      ),
                      onPressed: () {
                        widget.onReadPressed!();
                        setState(() {});
                      }),
                if (widget.characteristic.properties.write) //if there's a write
                  IconButton(
                      icon: Icon(Icons.circle, color: Colors.blue),
                      onPressed: () {
                        widget.onWritePressed!();
                        setState(() {});
                      }),
                // IconButton(
                //     icon: Icon(Icons.circle, color: Colors.green),
                //     onPressed: () {
                //       widget.onWritePressedTwo!();
                //       setState(() {});
                //     }),
                // IconButton(
                //     onPressed: () {
                //       widget.onWritePressedRed!();
                //       setState(() {});
                //     },
                //     icon: Icon(
                //       Icons.circle,
                //       color: Colors.redAccent,
                //     )),
                if (widget.characteristic.properties.notify ||
                    widget.characteristic.properties
                        .indicate) //if there is a notify or indicate
                  TextButton(
                      child: Text(widget.characteristic.isNotifying
                          ? "Stop Run" //unsubscribe
                          : "Start Run"), //subscribe
                      onPressed: () {
                        widget.onNotificationPressed!();
                        setState(() {});
                      })
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: const EdgeInsets.all(0.0),
          ),
          children: widget.descriptorTiles,
        );
      },
    );
  } //ends a widget build section
} //ends class charactertistic tile state/////////////////////////
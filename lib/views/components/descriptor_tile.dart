import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DescriptorTile extends StatelessWidget {
  //descriptor class
  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onWritePressedTwo; //added
  final VoidCallback? onWritePressedRed;

  const DescriptorTile(
      {Key? key,
      required this.descriptor,
      this.onReadPressed,
      this.onWritePressed,
      this.onWritePressedTwo,
      this.onWritePressedRed}) //added
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text('0x${descriptor.descriptorUuid.toString().toUpperCase()}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color))
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.onValueReceived,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        //second UI section
        //these seem to be the descriptor options
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_download, //read
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.circle, //write //blue
              color: Colors.blue,
            ),
            onPressed: onWritePressed,
          ),
          IconButton(
              onPressed: onWritePressedTwo, //also write //green
              icon: Icon(
                Icons.circle,
                color: Colors.green,
              )),
          IconButton(
              onPressed: onWritePressedRed,
              icon: Icon(Icons.circle, color: Colors.redAccent))
        ],
      ),
    );
  }
} //descriptor tile class
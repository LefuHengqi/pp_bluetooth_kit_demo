
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_demo/Device/device_apple.dart';
import 'package:pp_bluetooth_kit_demo/Device/device_banana.dart';
import 'package:pp_bluetooth_kit_demo/Device/device_coconut.dart';
import 'package:pp_bluetooth_kit_demo/Device/device_ice.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.title});

  final String title;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {

  bool _isScanning = false;
  List<PPDeviceModel> _scanResults = [];

  @override
  void initState() {

    //Monitor Bluetooth permission changes
    PPBluetoothKitManager.addBlePermissionListener(callBack: (permission) {
      print('Bluetooth permission state changed:$permission');
    });

    // Monitor scan status
    PPBluetoothKitManager.addScanStateListener(callBack: (scanning) {
      _isScanning = scanning;
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }


  Future _onScanPressed() async {
    _scanResults = [];
    PPBluetoothKitManager.startScan((device) {
      print('Scan result:${device.toJson()}');

      _scanResults.add(device);
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future _onStopPressed() async {
    PPBluetoothKitManager.stopScan();
  }

  Widget _buildScanButton(BuildContext context) {
    if (_isScanning) {
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: _onStopPressed,
        backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(child: const Text("SCAN"), onPressed: _onScanPressed);
    }
  }

  void _handleDeviceTap(PPDeviceModel device, int index) {

    switch(device.getDevicePeripheralType()) {
      case PPDevicePeripheralType.apple:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceApple(device: device),
          ),
        );
        break;
      case PPDevicePeripheralType.coconut:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceCoconut(device: device),
          ),
        );
        break;
      case PPDevicePeripheralType.banana:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceBanana(device: device),
          ),
        );
        break;
      case PPDevicePeripheralType.ice:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceIce(device: device),
          ),
        );
        break;
      default:
        print('undefined-${device.getDevicePeripheralType()}');
        break;
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _scanResults.length,
          itemBuilder: (context, index) {
            final device = _scanResults[index];

            return InkWell(
              onTap: () {
                _handleDeviceTap(device, index);
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name:${device.deviceName}\t\tRSSI:${device.rssi}\nMac:${device.deviceMac}\nsettingId:${device.deviceSettingId}\nadvLength:${device.advLength}\t\tsign:${device.sign}\nPeripheralType:${device.getDevicePeripheralType()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildScanButton(context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
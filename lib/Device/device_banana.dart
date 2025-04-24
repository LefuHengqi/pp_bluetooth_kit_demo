
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_demo/Common/custom_widgets.dart';
import 'package:pp_bluetooth_kit_demo/Common/define.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_banana.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';

class DeviceBanana extends StatefulWidget {
  final PPDeviceModel device;

  const DeviceBanana({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceBanana> createState() => _DeviceBananaState();
}

class _DeviceBananaState extends State<DeviceBanana> {

  final ScrollController _gridController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  String _dynamicText = '';
  PPUnitType _unit = PPUnitType.Unit_KG;
  PPDeviceConnectionState _connectionStatus = PPDeviceConnectionState.disconnected;
  double _weightValue = 0;
  String _measurementStateStr = '';

  final List<GridItem> _gridItems = [

  ];

  @override
  void initState() {

    final ppDevice = widget.device;
    PPBluetoothKitManager.connectDevice(ppDevice, callBack: (state) {
      _updateText('connection status：$state');

      _updateText('receiveDeviceData');
      //Receive broadcast data
      PPPeripheralBanana.receiveDeviceData(ppDevice);

      _connectionStatus = state;
      if (mounted) {
        setState(() {});
      }
    });

    // Listen to the measurement data, only the last one of the multiple listeners will take effect, it is recommended that the app registers only one globally.
    PPBluetoothKitManager.addMeasurementListener(callBack: (measurementState, dataModel, device) {
      _weightValue = dataModel.weight / 100.0;

      switch (measurementState) {
        case PPMeasurementDataState.completed:
          _measurementStateStr = 'state:completed';
          break;
        case PPMeasurementDataState.measuringHeartRate:
          _measurementStateStr = 'state:measuringHeartRate';
          break;
        case PPMeasurementDataState.measuringBodyFat:
          _measurementStateStr = 'state:measuringBodyFat';
          break;
        default:
          _measurementStateStr = 'state:processData';
          break;
      }

      if (mounted) {
        setState(() {});
      }
    });

    _scrollController.addListener(() {});

    super.initState();
  }

  Future<void> _handle(String title) async {
    if (_connectionStatus != PPDeviceConnectionState.connected) {
      _updateText('Device Disconnect');
      return;
    }
  }


  void _updateText(String text) {
    _dynamicText = _dynamicText + '\n$text';
    if (mounted) {
      setState(() {});
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showWifiInputDialog(BuildContext context, Function(String ssid, String password) callBack) {
    final TextEditingController _ssidController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Wi-Fi information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('SSID: ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: TextField(
                      controller: _ssidController,
                      decoration: const InputDecoration(
                        hintText: 'Enter the Wi-Fi name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Password: ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: false, // 明文显示
                      decoration: const InputDecoration(
                        hintText: 'Enter the Wi-Fi password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final ssid = _ssidController.text;
                final password = _passwordController.text;
                Navigator.pop(context);
                callBack(ssid, password);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _gridController.dispose();
    _scrollController.dispose();
    PPBluetoothKitManager.stopScan();
    PPBluetoothKitManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banana')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${_connectionStatus == PPDeviceConnectionState.connected ? ' connected' : ' disconnect'}', // 替换_connectionStatus为你的实际连接状态变量
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'weight: $_weightValue KG    $_measurementStateStr', // 替换_weightValue为你的实际重量值变量
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: MediaQuery.of(context).size.width - 16,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    _dynamicText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),


          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(8),
              child: Scrollbar(
                controller: _gridController,
                child: GridView.builder(
                  controller: _gridController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _gridItems.length,
                  itemBuilder: (context, index) {
                    return GridActionItem(
                      item: _gridItems[index],
                      onTap: () async {

                        final model = _gridItems[index];
                        final title = model.title;
                        _handle(title);

                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
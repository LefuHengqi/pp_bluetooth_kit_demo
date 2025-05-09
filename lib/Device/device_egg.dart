import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_demo/Common/Define.dart';
import 'package:pp_bluetooth_kit_demo/Common/custom_widgets.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_egg.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';


class DeviceEgg extends StatefulWidget {
  final PPDeviceModel device;

  const DeviceEgg({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceEgg> createState() => _DeviceEggState();
}

class _DeviceEggState extends State<DeviceEgg> {

  final ScrollController _gridController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  String _dynamicText = '';
  PPUnitType _unit = PPUnitType.Unit_KG;
  PPDeviceConnectionState _connectionStatus = PPDeviceConnectionState.disconnected;
  double _weightValue = 0;
  String _measurementStateStr = '';

  final List<GridItem> _gridItems = [
    GridItem(DeviceMenuType.changeUnit.value),
    GridItem(DeviceMenuType.toZero.value),
  ];

  @override
  void initState() {

    final ppDevice = widget.device;
    PPBluetoothKitManager.connectDevice(ppDevice, callBack: (state) {
      _updateText('connection status：$state');

      _connectionStatus = state;
      if (mounted) {
        setState(() {});
      }
    });

    // Listen to the measurement data, only the last one of the multiple listeners will take effect.
    PPBluetoothKitManager.addKitchenMeasurementListener(callBack: (measurementState, dataModel, device) {
      _weightValue = dataModel.weight / 10.0;

      final msg = 'weight:$_weightValue measurementState:$measurementState';
      print(msg);

      switch (measurementState) {
        case PPMeasurementDataState.completed:
          _measurementStateStr = 'state:completed';

          _updateText(msg);
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

    try {

      if (title == DeviceMenuType.changeUnit.value) {
        _updateText('syncUnit:$_unit');
        _unit = _unit == PPUnitType.UnitG ? PPUnitType.UnitMLWater : PPUnitType.UnitG;
        final ret = await PPPeripheralEgg.syncUnit(_unit).timeout(const Duration(seconds: 3));
        _updateText('syncUnit-return:$ret');
      }

      if (title == DeviceMenuType.toZero.value) {
        _updateText('toZero');
        final ret = PPPeripheralEgg.toZero().timeout(const Duration(seconds: 3));
        _updateText('toZero-return:$ret');

      }

    } on TimeoutException catch (e) {
      final msg = 'TimeoutException:$e';
      print(msg);
      _updateText(msg);
    } catch(e) {
      final msg = 'Exception:$e';
      print(msg);
      _updateText(msg);
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
      appBar: AppBar(title: const Text('Egg')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${_connectionStatus == PPDeviceConnectionState.connected ? ' connected' : ' disconnect'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'weight: $_weightValue g    $_measurementStateStr',
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
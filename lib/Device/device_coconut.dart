
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pp_bluetooth_kit_demo/Common/Define.dart';
import 'package:pp_bluetooth_kit_demo/Common/custom_widgets.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_coconut.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_body_base_model.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_user.dart';


class DeviceCoconut extends StatefulWidget {
  final PPDeviceModel device;

  const DeviceCoconut({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceCoconut> createState() => _DeviceCoconutState();
}

class _DeviceCoconutState extends State<DeviceCoconut> {

  final ScrollController _gridController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  String _dynamicText = '';
  PPUnitType _unit = PPUnitType.Unit_KG;
  PPDeviceConnectionState _connectionStatus = PPDeviceConnectionState.disconnected;
  double _weightValue = 0;
  String _measurementStateStr = '';

  final List<GridItem> _gridItems = [
    GridItem(DeviceMenuType.syncTime.value),
    GridItem(DeviceMenuType.changeUnit.value),
    GridItem(DeviceMenuType.fetchHistory.value),
    GridItem(DeviceMenuType.getPower.value),
    GridItem(DeviceMenuType.getDeviceInfo.value),
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

    // Listen to the measurement data, only the last one of the multiple listeners will take effect, it is recommended that the app registers only one globally.
    PPBluetoothKitManager.addMeasurementListener(callBack: (measurementState, dataModel, device) {
      _weightValue = dataModel.weight / 100.0;

      final msg = 'weight:$_weightValue measurementState:$measurementState dataModel:${dataModel.toJson()}';
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

      if (title == DeviceMenuType.syncTime.value) {
        _updateText('syncTime');

        final ret = await PPPeripheralCoconut.syncTime();

        _updateText('syncTime-return:$ret');

      }
      if (title == DeviceMenuType.changeUnit.value) {
        _updateText('syncUnit:$_unit');
        _unit = _unit == PPUnitType.Unit_KG ? PPUnitType.Unit_LB : PPUnitType.Unit_KG;
        final deviceUser = PPDeviceUser(unitType: _unit,age: 20, userHeight: 170, sex: PPUserGender.female);
        await PPPeripheralCoconut.syncUnit(deviceUser);

      }
      if (title == DeviceMenuType.fetchHistory.value) {
        _updateText('fetchHistoryData');
        PPPeripheralCoconut.fetchHistoryData(callBack: (dataList, isSuccess){
          _updateText('History data count:${dataList.length}');

          if (isSuccess && dataList.length > 0) {
            _updateText('Perform deletion of historical data:deleteHistoryData');
            PPPeripheralCoconut.deleteHistoryData();
          }

          for (PPBodyBaseModel model in dataList) {
            print('history weight:${model.weight} isSuccess:$isSuccess');
          }

        });

      }
      if (title == DeviceMenuType.getPower.value) {
        _updateText('fetchBatteryInfo');
        PPPeripheralCoconut.fetchBatteryInfo(continuity: true, callBack: (power) {
          _updateText('power:$power');
        });

      }
      if (title == DeviceMenuType.getDeviceInfo.value) {
        _updateText('fetchDeviceInfo');
        final device180AModel = await PPPeripheralCoconut.fetchDeviceInfo().timeout(const Duration(seconds: 5));
        _updateText('firmwareRevision:${device180AModel?.firmwareRevision} modelNumber:${device180AModel?.modelNumber}');
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
      appBar: AppBar(title: const Text('Coconut')),
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
                  'weight: $_weightValue KG    $_measurementStateStr',
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


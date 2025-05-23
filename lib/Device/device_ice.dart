

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pp_bluetooth_kit_demo/Common/Define.dart';
import 'package:pp_bluetooth_kit_demo/Common/custom_widgets.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_peripheral_ice.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_body_base_model.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_wifi_result.dart';

class DeviceIce extends StatefulWidget {
  final PPDeviceModel device;

  const DeviceIce({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceIce> createState() => _DeviceIceState();
}

class _DeviceIceState extends State<DeviceIce> {

  final ScrollController _gridController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  String _dynamicText = '';
  PPUnitType _unit = PPUnitType.Unit_KG;
  PPDeviceConnectionState _connectionStatus = PPDeviceConnectionState.disconnected;
  double _weightValue = 0;
  String _measurementStateStr = '';
  Timer? _timer;

  final List<GridItem> _gridItems = [
    GridItem(DeviceMenuType.syncTime.value),
    GridItem(DeviceMenuType.changeUnit.value),
    GridItem(DeviceMenuType.fetchHistory.value),
    GridItem(DeviceMenuType.getPower.value),
    GridItem(DeviceMenuType.configNetwork.value),
    GridItem(DeviceMenuType.queryWifiConfig.value),
    GridItem(DeviceMenuType.getDeviceInfo.value),
    GridItem(DeviceMenuType.restoreFactory.value),
    GridItem(DeviceMenuType.turnOnHeartRate.value),
    GridItem(DeviceMenuType.turnOffHeartRate.value),
    GridItem(DeviceMenuType.getHeartRateSW.value),
    GridItem(DeviceMenuType.turnOnImpedance.value),
    GridItem(DeviceMenuType.turnOffImpedance.value),
    GridItem(DeviceMenuType.getImpedanceSW.value),
    GridItem(DeviceMenuType.syncDeviceLog.value),
    GridItem(DeviceMenuType.userOTA.value),
  ];

  @override
  void initState() {

    final ppDevice = widget.device;
    PPBluetoothKitManager.connectDevice(ppDevice, callBack: (state) {
      _updateText('connection status：$state');

      // After the connection is successful, keep alive instructions are sent regularly to keep the device connected for a long time
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 10), (timer) {
        PPPeripheralIce.keepAlive();
      });

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

        final ret = await PPPeripheralIce.syncTime();

        _updateText('syncTime-return:$ret');

      }
      if (title == DeviceMenuType.changeUnit.value) {
        _updateText('syncUnit:$_unit');
        _unit = _unit == PPUnitType.Unit_KG ? PPUnitType.Unit_LB : PPUnitType.Unit_KG;
        await PPPeripheralIce.syncUnit(_unit);

      }
      if (title == DeviceMenuType.fetchHistory.value) {
        _updateText('fetchHistoryData');
        PPPeripheralIce.fetchHistoryData(callBack: (dataList, isSuccess){
          _updateText('History data count:${dataList.length}');

          if (isSuccess && dataList.length > 0) {
            _updateText('Perform deletion of historical data:deleteHistoryData');
            PPPeripheralIce.deleteHistoryData();
          }

          for (PPBodyBaseModel model in dataList) {
            print('history weight:${model.weight} isSuccess:$isSuccess');
          }

        });

      }
      if (title == DeviceMenuType.getPower.value) {
        _updateText('fetchBatteryInfo');
        PPPeripheralIce.fetchBatteryInfo(continuity: true, callBack: (power) {
          _updateText('power:$power');
        });

      }
      if (title == DeviceMenuType.configNetwork.value) {

        _showWifiInputDialog(context, (ssid, password) async {
          _updateText('configWifi');
          _updateText('ssid:$ssid password:$password');
          _updateText('Please wait...');

          // ‘domain’ needs to use the domain name configured by your server
          PPWifiResult result = await PPPeripheralIce.configWifi(domain: "http://120.79.144.170:6032", ssId: ssid, password: password);
          _updateText('Distribution network results:${result.success}');
        });
      }
      if (title == DeviceMenuType.queryWifiConfig.value) {
        _updateText('fetchWifiInfo');
        final ssId = await PPPeripheralIce.fetchWifiInfo().timeout(const Duration(seconds: 5));
        _updateText('ssId:$ssId');
      }
      if (title == DeviceMenuType.getDeviceInfo.value) {
        _updateText('fetchDeviceInfo');
        final device180AModel = await PPPeripheralIce.fetchDeviceInfo().timeout(const Duration(seconds: 5));
        _updateText('firmwareRevision:${device180AModel?.firmwareRevision} modelNumber:${device180AModel?.modelNumber}');
      }
      if (title == DeviceMenuType.restoreFactory.value) {
        _updateText('resetDevice');
        PPPeripheralIce.resetDevice();
      }
      if (title == DeviceMenuType.turnOnHeartRate.value) {
        _updateText('heartRateSwitchControl - open');
        final ret = await PPPeripheralIce.heartRateSwitchControl(true);
        _updateText('heartRateSwitchControl return:$ret');
      }
      if (title == DeviceMenuType.turnOffHeartRate.value) {
        _updateText('heartRateSwitchControl - close');
        final ret = await PPPeripheralIce.heartRateSwitchControl(false);
        _updateText('heartRateSwitchControl return:$ret');
      }
      if (title == DeviceMenuType.getHeartRateSW.value) {
        _updateText('fetchHeartRateSwitch');
        final ret = await PPPeripheralIce.fetchHeartRateSwitch();
        _updateText('fetchHeartRateSwitch return:$ret');
      }
      if (title == DeviceMenuType.turnOnImpedance.value) {
        _updateText('impedanceSwitchControl - open');
        final ret = await PPPeripheralIce.impedanceSwitchControl(true);
        _updateText('impedanceSwitchControl return:$ret');
      }
      if (title == DeviceMenuType.turnOffImpedance.value) {
        _updateText('impedanceSwitchControl - close');
        final ret = await PPPeripheralIce.impedanceSwitchControl(false);
        _updateText('impedanceSwitchControl return:$ret');
      }
      if (title == DeviceMenuType.getImpedanceSW.value) {
        _updateText('fetchImpedanceSwitch');
        final ret = await PPPeripheralIce.fetchImpedanceSwitch();
        _updateText('fetchImpedanceSwitch return:$ret');
      }
      if (title == DeviceMenuType.syncDeviceLog.value) {
        _updateText('syncDeviceLog');
        final directory = await getApplicationDocumentsDirectory();
        final logDirectory = '$directory/DeviceLog';
        PPPeripheralIce.syncDeviceLog(logDirectory, callBack: (progress, isFailed, filePath) {
          _updateText('sync log-isFailed:$isFailed filePath:$filePath');
        });

      }
      if (title == DeviceMenuType.userOTA.value) {
        _updateText('wifiOTA');
        final ret = await PPPeripheralIce.wifiOTA();
        _updateText('wifiOTA return:$ret');
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ice')),
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
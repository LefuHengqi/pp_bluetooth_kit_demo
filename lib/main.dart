import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pp_bluetooth_kit_flutter/ble/pp_bluetooth_kit_manager.dart';
import 'package:pp_bluetooth_kit_flutter/enums/pp_scale_enums.dart';
import 'package:pp_bluetooth_kit_flutter/model/pp_device_model.dart';
import 'package:pp_bluetooth_kit_flutter/utils/pp_bluetooth_kit_logger.dart';

import 'scan_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Monitor logs
  PPBluetoothKitLogger.addListener(callBack: (log) {
    print('SDK-Log:$log');
  });

  // init SDK
  final path = 'config/lefu.config';
  String content = await rootBundle.loadString(path);
  PPBluetoothKitManager.initSDK('lefub60060202a15ac8a', 'UCzWzna/eazehXaz8kKAC6WVfcL25nIPYlV9fXYzqDM=', content);



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScanPage(title: 'Scan Device'),
    );
  }
}



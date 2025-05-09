
enum DeviceMenuType {
  connectDevice('Connect Device'),
  startMeasure('Start measure'),
  stopMeasure('Stop measure'),
  syncTime('Sync time'),
  fetchHistory('Fetch History'),
  getVisitorHistory('Get visitor history'),
  getUserHistory('Get user history'),
  syncUserList('Sync user list'),
  deleteUser('Delete user'),
  changeUnit('Change unit'),
  deleteHistoryData('Delete History Data'),
  toZero('To Zero'),
  distributionNetwork('Distribution network'),
  changeBuzzerGate('Change Buzzer Gate'),
  searchWIFI('1-Search nearby Wi-Fi'),
  configNetwork('2-Config network'),
  getNetworkInfo('Get network info'),
  restoreFactory('Restore Factory'),
  queryDeviceTime('Query Device Time'),
  deleteWIFI('Delete WIFI'),
  queryWifiConfig('Query Wifi Config'),
  queryDNS('Query DNS'),
  testOTA('Start Test OTA'),
  userOTA('Start User OTA'),
  getDeviceInfo('Get device information'),
  turnOnHeartRate('Turn on the heart rate'),
  turnOffHeartRate('Turn off heart rate'),
  getHeartRateSW('Get the heart rate switch'),
  turnOnImpedance('Turn on the impedance switch'),
  turnOffImpedance('Turn off the impedance switch'),
  getImpedanceSW('Get impedance switch'),
  syncDeviceLog('Sync device logs'),
  getPower('Get power');

  final String value;
  const DeviceMenuType(this.value);

  @override
  String toString() => value;
}



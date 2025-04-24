
enum DeviceMenuType {
  connectDevice('connect Device'),
  startMeasure('start measure'),
  syncTime('Sync time'),
  fetchHistory('Fetch History'),
  changeUnit('Change unit'),
  deleteHistoryData('Delete History Data'),
  toZero('to Zero'),
  distributionNetwork('distribution network'),
  changeBuzzerGate('change Buzzer Gate'),
  configNetwork('Config network'),
  getNetworkInfo('Get network info'),
  restoreFactory('Restore Factory'),
  queryDeviceTime('Query Device Time'),
  deleteWIFI('Delete WIFI'),
  queryWifiConfig('Query Wifi Config'),
  queryDNS('Query DNS'),
  testOTA('Start Test OTA'),
  userOTA('Start User OTA'),
  getDeviceInfo('Get device information'),
  getPower('Get power');

  final String value;
  const DeviceMenuType(this.value);

  @override
  String toString() => value;
}



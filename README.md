# Quick Links

1. [Flutter SDK Integration](https://xinzhiyun.feishu.cn/wiki/KNT5wGk5hi8Sg3kHlN1cgPVsnnf?from=from_copylink)
2. [Flutter SDK scans devices](https://xinzhiyun.feishu.cn/wiki/KBlJwLrTuiZ7vFkuBJqcN78snYa?from=from_copylink)
3. [Flutter SDK Integrated body scale](https://xinzhiyun.feishu.cn/wiki/YwVTwgkK2iwHz7kTwtGcL7Ngnbf?from=from_copylink)
4. [Flutter SDK Integrated kitchen scale](https://xinzhiyun.feishu.cn/wiki/EJIdwA9dcimGjvkYE4UcaVrDnpb?from=from_copylink)
5. [Flutter Example Program](https://github.com/LefuHengqi/pp_bluetooth_kit_demo)
6. [Flutter SDK集成](https://xinzhiyun.feishu.cn/wiki/BHIkwHoXFia6eEkjjVick9IBnEd?from=from_copylink)
7. [Flutter SDK扫描设备](https://xinzhiyun.feishu.cn/wiki/K36Nw9Zzcir6EIk2Km8caiN5nHd?from=from_copylink)
8. [Flutter SDK人体秤接入](https://xinzhiyun.feishu.cn/wiki/WriFwY6HRiuidwkWAgQcYPDvnIi?from=from_copylink)
9. [Flutter SDK厨房秤接入](https://xinzhiyun.feishu.cn/wiki/X2MnwCZqqiRUZQkfWXtcuBZRnXc?from=from_copylink)
10. [Flutter Example Program](https://github.com/LefuHengqi/pp_bluetooth_kit_demo)

# Overview

`pp_bluetooth_kit_flutter` is a Flutter SDK encapsulated for body scales and food scales, including logic such as Bluetooth scanning, Bluetooth connection, and data parsing.

## Sample Program

To enable customers to quickly implement weighing and corresponding functions, a sample program is provided`pp_bluetooth_kit_demo`, which includes device scanning, device connection, and function demonstrations for body scales/food scales. The access address of the sample program is:[Flutter Sample Program](https://github.com/LefuHengqi/pp_bluetooth_kit_demo)

## Integration Method

Obtain ​**​ AppKey ​**​, **​ AppSecret and config file ​**

### 1.1 Register[ LeFu Open Platform ](https://uniquehealth.lefuenergy.com/unique-open-web/#/login)

Registration is required on the[ Lefu Open Platform ](https://uniquehealth.lefuenergy.com/unique-open-web/#/home), address: https://lefuhengqi.apifox.cn/doc-2624410

### 1.2 **Apply for AppKey and AppSecret**

After completing the registration in [Lefu Open Platform ](https://uniquehealth.lefuenergy.com/unique-open-web/#/home), you can get the **AppKey ​**and **AppSecret of the current account by filling in the complete company information**

![](https://xinzhiyun.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDYyZTg4NTRjOWQ2OGJmNjg3MjRlMGYxYTMwZjdjMmZfckNKVFdPOFRyWWRjVVRwbmgyY1c5bUJTVWJHMUpNV2xfVG9rZW46S01MU2JWUnBib3JGbEJ4bnFiS2NtVWIxbm5nXzE3NTQwNDYxODc6MTc1NDA0OTc4N19WNA)

### 1.3 Configure Devices

You need to configure the device to be used before you can scan for the corresponding device. For the tutorial on configuring the device, please refer to:[Lefu Open Platform Configuration Device Guide](https://xinzhiyun.feishu.cn/docx/Gw38d5JskoShyFxKnwIcvIaznhb?from=from_copylink)

### 1.4 **​ Obtain the config file ​**

After you have completed configuring the device, please go to [ the Personal Center of Lefu Open Platform ](https://uniquehealth.lefuenergy.com/unique-open-web/#/usermsg) to download the corresponding config file

### 1.5 SDK Integration

Add the following references to the **pubspec.yaml** file in the Flutter project **: ​**

```
pp_bluetooth_kit_flutter:
​    ​git:
      url: https://github.com/LefuHengqi/pp_bluetooth_kit_flutter.git
      ref: 0.0.34
```

Create a new folder in the root directory of the Flutter project, named: config; rename the **config** file downloaded in step 1.4 to: lefu.config, and add the corresponding configuration to the **pubspec.yaml** file:

```
assets:
  - config/lefu.config
```

Execute the following command to install the SDK:

```
flutter pub get
```

### 1.6 SDK Initialization

It is recommended to initialize the SDK in the **main.dart** file, where **AppKey** and **AppSecret** are the information applied for in Step 1.2

```
final path = 'config/lefu.config';
String content = await rootBundle.loadString(path);
PPBluetoothKitManager.initSDK(AppKey, AppSecret, content);
```

### 1.7 Add Bluetooth permissions

#### iOS Bluetooth Permission

Add Bluetooth permissions to the`Info.plist`file in the iOS project

```XML
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Your consent is required to use Bluetooth for device connection</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Your consent is required to use Bluetooth for device connection</string>
```

#### Android Bluetooth Permissions

Add Bluetooth permissions to the`AndroidManifest.xml`file in the Android project

```XML
<!-- 蓝牙相关权限 -->
<uses-permission
    android:name="android.permission.BLUETOOTH"
    android:maxSdkVersion="30" />
<uses-permission
    android:name="android.permission.BLUETOOTH_ADMIN"
    android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation"
    tools:targetApi="s" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Commercial Version Program

* Search and download "Unique Health" on the App Store
* You can also scan the QR code below to download

![](https://xinzhiyun.feishu.cn/space/api/box/stream/download/asynccode/?code=MDllMzViZTA5Yjc0OGJmNDA5NTkzMDc0ZWI3MzUyMzRfaHFENzNyUmtPTU9TTjFFWUcwZm5odXM3NlYyS0N4bm1fVG9rZW46SlZMSmJGZ0trb3lKNkF4SDV1dmMyeEV2bjBnXzE3NTQwNDYxODc6MTc1NDA0OTc4N19WNA)

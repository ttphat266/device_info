// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String deviceInfo = 'Fetching device info...';
  String serialNumber = 'Fetching serial number...';
  String imeiNumber = 'Fetching IMEI number...';

  String serialNumber1 = 'Fetching serial number...';
  String imeiNumber1 = 'Fetching IMEI number...';

  @override
  void initState() {
    super.initState();
    getDeviceDetails();
  }

  Future<void> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    // Request permissions
    var status = await Permission.phone.status;

    if (!status.isGranted) {
      await Permission.phone.request();
    }

    if (await Permission.phone.isGranted) {
      final DeviceInfoPlugin deviceInfoPlugin1 = DeviceInfoPlugin();
      final AndroidDeviceInfo androidDeviceInfo1 =
          await deviceInfoPlugin1.androidInfo;

      final String imeiNumber1 = androidDeviceInfo1.id;
      final String serialNumber1 = androidDeviceInfo1.id;
      print('imeiNumber1: $imeiNumber1');
      print('serialNumber1: $serialNumber1');
      print('data: ${androidDeviceInfo1.data}');

      try {
        if (Theme.of(context).platform == TargetPlatform.android) {
          var androidInfo = await deviceInfoPlugin.androidInfo;
          setState(() {
            serialNumber = androidInfo.serialNumber;
            deviceInfo = '''
              Model: ${androidInfo.model}
              Version: ${androidInfo.version.release}
              Device: ${androidInfo.device}
              Product: ${androidInfo.product}
              ID: ${androidInfo.id}
              Brand: ${androidInfo.brand}
              Manufacturer: ${androidInfo.manufacturer}
              Android Version: ${androidInfo.version.release}
              Hardware: ${androidInfo.hardware}
              SerialNumber: ${androidInfo.serialNumber}
              ''';
          });
        } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          var iosInfo = await deviceInfoPlugin.iosInfo;
          setState(() {
            serialNumber = 'Not available on iOS';
            deviceInfo = '''
              Model: ${iosInfo.model}
              System Version: ${iosInfo.systemVersion}
              ''';
          });
        } else {
          setState(() {
            serialNumber = 'Unsupported platform';
            deviceInfo = 'Unsupported platform';
          });
        }
        final message = '''
                    Serial Number: $serialNumber'
                    IMEI Number: $imeiNumber
                    Device Info:\n$deviceInfo
                    ''';
        //phat
        // sendMessage(message);
      } catch (e) {
        setState(() {
          serialNumber = 'Failed to get serial number: $e';
          deviceInfo = 'Failed to get device info: $e';
        });
      }

      // Get IMEI Number (Android)
      try {
        // var mobileNumber = await MobileNumber.mobileNumber;
        setState(() {
          // imeiNumber = mobileNumber ?? 'Unavailable';
        });
      } catch (e) {
        setState(() {
          imeiNumber = 'Failed to get IMEI number: $e';
        });
      }
    } else {
      setState(() {
        serialNumber = 'Permission denied';
        imeiNumber = 'Permission denied';
        deviceInfo = 'Permission denied';
      });
    }
  }

  Future<void> sendMessage() async {
    print('⏯️ Begin send message to tele bot');
    final message = '''
                    Serial Number: $serialNumber'
                    IMEI Number: $imeiNumber
                    Device Info:\n$deviceInfo
                    ''';
    const url =
        'https://api.telegram.org/bot7307951703:AAHEYXvTUiW-O8YXU6_WxgLrIcJIQ-fVtyc/sendMessage';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'chat_id': '-4269483478',
        'text': message,
      },
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serial Number: $serialNumber'),
            Text('IMEI Number: $imeiNumber'),
            const SizedBox(height: 20),
            Text('Device Info:\n$deviceInfo'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getDeviceDetails,
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: sendMessage(),
            //   child: const Text('Send to Bot'),
            // ),
          ],
        ),
      ),
    );
  }
}

class IMEIServices {
  static const platform = MethodChannel('device_info');

  static Future<String?> getIMEI() async {
    try {
      final String? imei = await platform.invokeMethod('getIMEI');
      return imei;
    } on PlatformException catch (e) {
      print("Failed to get IMEI: '${e.message}'.");
      return null;
    }
  }
}

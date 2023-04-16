import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async'; // Timerクラスを使用するために必要なimport文

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  //ranAppよりも前に何かしたい場合に追記するらしい
  WidgetsFlutterBinding.ensureInitialized();

  //iOS設定
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // iosの初期設定
  const InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSwitched = false; // スイッチの初期状態をオフに設定
  int notificationInterval = 10; // 通知の間隔（秒単位）
  Timer? notificationTimer; // 通知を表示するためのタイマー

  @override
  void initState() {
    super.initState();
    // スイッチの初期状態がオンの場合、関数を実行
    if (isSwitched) {
      _startNotifications();
    }
  }

  void _startNotifications() {
    if (isSwitched) {
      notificationTimer =
          Timer.periodic(Duration(seconds: notificationInterval), (timer) {
        // 通知を表示する関数
        _showNotificationPeriodically();
      });
    }
  }

  // ios用の通知を呼び出すメソッド
  Future<void> _showNotificationPeriodically() async {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '通知タイトル',
      '通知の内容',
      platformChannelSpecifics,
      payload: '通知のペイロード',
    );
  }

  // 定期的に呼び出していた通知をキャンセルするメソッド
  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: isSwitched,
              onChanged: (bool value) {
                setState(() {
                  isSwitched = value;
                  // スイッチがオンになったら関数を実行
                  if (isSwitched) {
                    _startNotifications();
                  } else {
                    notificationTimer?.cancel();
                    _cancelNotification();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

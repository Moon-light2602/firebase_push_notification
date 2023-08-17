
import 'package:ex_firebase_push_notification/model/pushnotification_model.dart';
import 'package:ex_firebase_push_notification/notification_badge.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
          debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
  class _HomePageState extends State<HomePage>{

  //initialize some values
  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;

  PushNotification? _notificationInfo;

  //register notification
  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted the permission");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );
        setState(() {
          _totalNotificationCounter ++;
          _notificationInfo = notification;
        });

        if(notification != null){
          showSimpleNotification(Text(_notificationInfo!.title!),
          leading: NotificationBadge(totalNotification: _totalNotificationCounter),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2));
        }
      });
    }
    else {
      print("permission declined by user");
    }
  }

  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    }
  }


  @override
  void initState() {
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
      setState(() {
        _totalNotificationCounter ++;
        _notificationInfo = notification;
      });
    });
    //normal notification
    registerNotification();
    //when app is in terminated state
    checkForInitialMessage();

    _totalNotificationCounter = 0;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PushNotification'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("FlutterPushNotification",
          textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
            ),
            const SizedBox(height: 12,),
            NotificationBadge(totalNotification: _totalNotificationCounter),
            const SizedBox(height: 30,),

            _notificationInfo != null
              ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("TITLE: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16
                ),
                ),
                const SizedBox(height: 9,),
                Text("TITLE: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16
                  ),),
              ],
            )
                : Container()
          ],
        ),
      ),
    );
  }
}




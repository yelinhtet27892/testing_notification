import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingHandler(RemoteMessage message) async{
 await NotificationService.instance.setUpFlutterNotifications();
 await NotificationService.instance.showFlutterNotification(message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final messaging = FirebaseMessaging.instance;

  final localNotification = FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationInitialized = false;

  Future<void> initialize() async{

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingHandler);

    ///request permission
    await _requestPermission();

    ///set up messaging handler
    await _setUpMessagingHandler();

    ///get fcm token
    final token = await messaging.getToken();

    print("Get Token $token");

    await setUpFlutterNotifications();
  }

  Future<void> _requestPermission() async {
    final setting = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false);

    print("${setting.authorizationStatus}");
  }

  Future<void> setUpFlutterNotifications() async {
    if (isFlutterLocalNotificationInitialized) {
      return;
    }

    ///android set up
    const channel = AndroidNotificationChannel(
        "high_importance_channel", "High Importance Notification",
        description: "this channgel is used", importance: Importance.high);
    await localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    final initializationSetting =
        InitializationSettings(android: initializationSettingAndroid);

    ///flutter notification setup
    await localNotification.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (detail) {

        });
    isFlutterLocalNotificationInitialized = true;
  }

  Future<void> showFlutterNotification(RemoteMessage message) async{
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      localNotification.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "high_importance_channel", "High Importance Notification",
            channelDescription: "this channgel is used",
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  Future<void> _setUpMessagingHandler() async{
    FirebaseMessaging.onMessage.listen((message){
      showFlutterNotification(message);
    });
    ///background message
    FirebaseMessaging.onMessageOpenedApp.listen((_handleBackgroundMessage));

    ///open app
    final initialMessage = await messaging.getInitialMessage();
    if(initialMessage != null){
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message){
    if(message.data['type'] == 'chat'){

    }
  }



}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestNotificationPermission() async {
    NotificationSettings setting = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
      criticalAlert: true,
    );

    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (setting.authorizationStatus == AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } else {
      print('user denied permission');
    }
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification?.title.toString());
      print(message.notification?.body.toString());
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('refresh');
    });
  }
}

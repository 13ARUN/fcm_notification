// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else {
      debugPrint("User declined or has not accepted permission");
    }

    messaging.getToken().then((token) {
      if (token != null) {
        setState(() {
          _token = token;
        });
        debugPrint("FCM Token: $_token");
      }
    });

    messaging.onTokenRefresh.listen((newToken) {
      setState(() {
        _token = newToken;
      });
      debugPrint("FCM Token Refreshed: $_token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.notification?.title}");
      if (message.notification != null) {
        NotificationService.showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        debugPrint("Message clicked: ${message.notification!.title}");
      }
    });

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        "App opened from terminated state: ${initialMessage.notification?.title}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Background Notification")),
      body: Center(
        child: SelectableText(
          _token != null ? "FCM Token: $_token" : "Fetching token...",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';

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
      debugPrint("✅ User granted permission for notifications.");
    } else {
      debugPrint("❌ User declined or has not accepted notifications.");
    }

    _setupFCMListeners(messaging);
  }

  void _setupFCMListeners(FirebaseMessaging messaging) {
    messaging.getToken().then((token) {
      if (mounted) {
        setState(() {
          _token = token ?? "No token received";
        });
      }
      debugPrint("🔹 FCM Token: $_token");
    });

    messaging.onTokenRefresh.listen((newToken) {
      if (mounted) {
        setState(() {
          _token = newToken;
        });
      }
      debugPrint("🔄 FCM Token Refreshed: $_token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        "📩 Foreground message received: ${message.notification?.title}",
      );
      debugPrint("📨 Foreground message data: ${message.data}");

      if (message.notification != null) {
        NotificationService.showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('route')) {
        final route = message.data['route'];
        debugPrint("🟢 Navigating to: $route");

        if (mounted && route != null) {
          GoRouter.of(context).go(route);
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null && initialMessage.data.containsKey('route')) {
        final route = initialMessage.data['route'];
        debugPrint("🚀 Navigating to initial route: $route");

        if (mounted && route != null) {
          GoRouter.of(context).go(route);
        }
      }
    });

    messaging.subscribeToTopic("topic");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Notification")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              SelectableText(
                _token != null ? "FCM Token: $_token" : "Fetching token...",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    context.push('/details/42');
                  }
                },
                child: Text('Push to Details'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    context.push('/products');
                  }
                },
                child: Text('Push to Products'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// main.dart
import 'package:fcm_notification/firebase_options.dart';
import 'package:fcm_notification/pages/details_page.dart';
import 'package:fcm_notification/pages/products_page.dart';
import 'package:fcm_notification/pages/send_notification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/local_notification_service.dart';
import 'pages/home_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return HomePage();
      },
    ),
    GoRoute(
      path: '/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailPage(id: id!);
      },
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) {
        return ProductsPage();
      },
    ),
    GoRoute(
      path: '/send',
      builder: (context, state) {
        return SendNotificationPage();
      },
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(
    LocalNotificationService.backgroundMessageHandler,
  );
  await LocalNotificationService.setupNotificationChannel();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FCM Background Notification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}

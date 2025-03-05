import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FCMNotificationService {
  FCMNotificationService(this._dio);
  final Dio _dio;
  static const String _projectId = "fcmnotifications-d4128";

  Future<void> sendNotification(String title, String body) async {
    if (title.isEmpty || body.isEmpty) {
      throw Exception("Title and body are required");
    }

    try {
      final response = await _dio.post(
        "https://fcm.googleapis.com/v1/projects/$_projectId/messages:send",
        data: {
          "message": {
            "topic": "topic",
            "notification": {"title": title, "body": body},
            "data": {"route": "/send"},
            "android": {
              "priority": "high",
              "notification": {
                "channel_id": "high_priority_channel",
                "visibility": "public",
                "sound": "default",
                "default_sound": false,
              },
            },
          },
        },
      );
      debugPrint("Notification Sent: ${response.data}");
    } catch (e) {
      throw Exception("Failed to send notification: $e");
    }
  }
}

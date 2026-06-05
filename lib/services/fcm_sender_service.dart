import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmSenderService {
  static const String _projectId = 'my-project-433d3';

  // NOTE: This is a restricted approach used only because there's no backend.
  static const String _serviceAccountJson = '''
{
  "type": "service_account",
  "project_id": "my-project-433d3",
  "private_key_id": "12612f822405395ce4d4af878231d11d648de975",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCyuLaCUnlgjJV9\\nvh9r0ZjhZFcEw4mWyzFC217Gggqh43OUHJdIfwWPTQ/MMBhuoA1jWRTCSkFcib9O\\nxhHkYx6SPHCNTp1rv1p9t0G1Ca4WAbs6C/FhVKc0HBLfJr3315TFKSfjcYEbiHaC\\nqMOYqMXQhHNtV1TmA5hIgA39tJAAYhQAE/Xe7tU6c2twfvyR7idK5epGTheKDsHH\\nRof15mAJR01QBFbEvitcV8u0+rw8N2I22qHbTGYuz6TryyEXJnq7U5w6qwwyVO+S\\neCRyp8SjzDNNPSI3wRpegSzbMvzxF7TQ34Gt8fhh7M8i4QeRQmzpdb1lechy8sYm\\n3PNNhxL1AgMBAAECggEAC23Shgz+JBV5bdwdqEh0DV3cTrqubs05rjvXGLyyL14b\\nQwp9Bi7RTTOxYe5lcZWcpZDJyg7zlRZd/IygEkngZ5uj2vV/DafkAowYkJo43sFn\\nlrOy0PWX57Yv4sNYfKP1qJIUMfBNQFR+t6ZRM87/L3F47DIchMUQFPrTajkEyHFh\\n0gZBIda2lwZhIV/R+0hnq7a2DliCfbraLAtARgf3BJAQQiRV+gCBp3+6d37+ZE+D\\nikylsYp/9ZAWCu1rqBMf85tZy1fn1CgOmsEuOx9Pd6hR20fJhtNXXTVrT5/pAt7B\\nvmZIA1/Qe4XAf9p+oBsNBHnMB8yAoT68EOX0sKYSFQKBgQDfUYATsPY8itJEXYiT\\n2AmZnD2E/Sz8J+sdIOSIiXyNAe+05VXQtj/VaBHBRmy0AKEpdYbkmRM0gjbQpWDb\\nHorbeLvR6yiO+bPJ0VWWcASa74yXlNXRcxQZoGgeMUjde4rQ4Vl0rDezA1M5QGPY\\nCSnbt8MChGEey7eFanXhGgRe6wKBgQDM4GrD0MR3Wb+QB7nqN2UymY+Mf2XV6sL0\\nTxGnYqAf1tZLAvyz+HlZEbE+dgo4pzimt2uP7GO9D/oJaquYxRElDIQJLxfEIpXc\\nlpK0WiL5Y6GtNu3FhaVbHLqm4Wz8SePV4H7g/Jtuw28hmzSHRYjz7wGuA/E84R27\\nDA3K4U6dnwKBgQDYCxam9iohxANLlFlO/k+7RgXWJMBiaZPxqCKvXKMcH2VxUfTF\\nZ6s1n+qdWq5LLdi8LTEE8no78EVrcLLVCSU40gKSQLgKKdQfSN9OHKy330vaUWjR\\nqk0lxaM0omVlr+FJ1tkeIIX6LxtSZdKx65uNLqgARWVXz6mJ7sZ/sRXNZQKBgHcw\\njAxVdSb2KJLzW76d8ZrJaZDUQPt9c2PMaDnYD83WH59OIpPVF0uxFkt/Qp0I89VR\\n2hrF7JR+Kfm2fBQJedry+BGbuxjZAhRt6PVRhw1NYC60SQnjoXprMU+Kz+vKVOkF\\njOr5Krf6rLmBYMLdujonrvN8yaigUrqR3ahNAX6DAoGATzLK/+6E905VfKNzTCO6\\nP2ziOHHUAKwE/LgMzcTV89bFvevdJH+WyAhDlzZYU94nPz0vdN4hYFRl0wpGaUeo\\n0jGDferyru+584j4aXHwRreQwkx+wIGtFZZkEI8b/wudcwT/FX+2ZJYwuC2PDpEZ\\n3lz9cydaOG65DICJzIqWx7Q=\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-fbsvc@my-project-433d3.iam.gserviceaccount.com",
  "client_id": "115638090627740582666",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40my-project-433d3.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

  static Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(_serviceAccountJson);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final accessToken = client.credentials.accessToken.data;
    client.close();
    return accessToken;
  }

  static Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
  }) async {
    try {
      final token = await _getAccessToken();
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');

      // Save notification to Firestore first
      final notificationData = {
        'title': title,
        'body': body,
        'sentTime': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      await FirebaseFirestore.instance.collection('notifications').add(notificationData);

      final payload = {
        "message": {
          "topic": "all_users",
          "notification": {
            "title": title,
            "body": body,
          },
          "android": {
            "notification": {
              "channel_id": "high_importance_channel",
              "sound": "default",
              "click_action": "FLUTTER_NOTIFICATION_CLICK"
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "sound": "default"
              }
            }
          }
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (kDebugMode) {
        if (response.statusCode == 200) {
          print('Notification sent successfully to all users!');
        } else {
          print('Failed to send notification: ${response.statusCode}');
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending push notification: $e');
      }
    }
  }
}

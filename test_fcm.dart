import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:my_barishal_new/services/fcm_sender_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Testing FCM Sender...");
    await FcmSenderService.sendNotificationToAllUsers(title: "Test", body: "Test");
    print("Test finished");
    exit(0);
  } catch(e) {
    print("Error: $e");
    exit(1);
  }
}

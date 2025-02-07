import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import Firebase Core
import 'package:todo_notification/notification_service.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ Initialize Firebase before using any Firebase services
  await Firebase.initializeApp();

  /// ✅ Initialize Notification Service
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

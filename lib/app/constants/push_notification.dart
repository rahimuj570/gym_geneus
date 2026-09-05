import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';
import 'appconstants.dart';

// ------------------------ Local Notifications ------------------------
Future<void> initLocalNotifications() async {
  // Android settings
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings
  final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Initialization for both platforms
  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      print('Notification tapped with payload: ${details.payload}');
      // Handle tap logic here, e.g., navigate to a screen
    },
  );
}

// ------------------------ Show Notification ------------------------
Future<void> showNotification(RemoteMessage message) async {
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel', // channel id
    'Default Channel',
    importance: Importance.max,
    priority: Priority.high,
  );

  final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    message.notification.hashCode,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
    payload: message.data['payload'], // optional custom data
  );
}

// ------------------------ FCM Initialization ------------------------
Future<void> initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize local notifications
  await initLocalNotifications();

  // Request permissions for notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('❌ Notification permission denied');
    return;
  }

  // Get FCM token and store it
  final token = await messaging.getToken();
  final box = GetStorage();
  box.write('FCMToken', token);
  print("📲 FCM Token: $token");

  final String? loginToken = GetStorage().read<String>('loginToken');
  if (token != null && loginToken != null) {
    await sendTokenToBackend(token);
  }

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📥 Foreground notification: ${message.notification?.title}");
    showNotification(message);
  });

  // App opened from notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("➡️ App opened from notification: ${message.data}");
  });

  // Token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print("🔄 FCM Token refreshed: $newToken");
    await sendTokenToBackend(newToken);
  });
}

// ------------------------ Send Token to Backend ------------------------
Future<void> sendTokenToBackend(String token) async {
  const String _baseUrl = AppConstants.baseUrl;
  final String? loginToken = GetStorage().read<String>('loginToken');

  if (loginToken == null) return;

  final url = Uri.parse('$_baseUrl/utils/register_device_token/');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $loginToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'device_token': token}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('✅ Token successfully registered with backend');
  } else {
    print('❌ Failed to register token: ${response.statusCode} - ${response.body}');
  }
}

// ------------------------ Unregister Token ------------------------
Future<void> unregisterFCM() async {
  const String _baseUrl = AppConstants.baseUrl;
  final String? loginToken = GetStorage().read<String>('loginToken');
  final String? token = GetStorage().read<String>('FCMToken');

  if (loginToken == null || token == null) return;

  final url = Uri.parse('$_baseUrl/notification/unregister_device_token/');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $loginToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'token': token}),
  );

  if (response.statusCode == 200) {
    print('✅ Token successfully unregistered with backend');
  } else {
    print('❌ Failed to unregister token: ${response.statusCode} - ${response.body}');
  }
}
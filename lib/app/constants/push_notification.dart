import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';
import 'appconstants.dart';
import '../services/api_client.dart';

// ------------------------ Notification Channel ------------------------
const AndroidNotificationChannel defaultNotificationChannel =
    AndroidNotificationChannel(
  'default_channel', // id
  'Default Channel', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
);

// ------------------------ Local Notifications ------------------------
Future<void> initLocalNotifications() async {
  // Android settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Initialization for both platforms
  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  // Create notification channel for Android 8.0+
  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(defaultNotificationChannel);
    // Request permission for Android 13+
    await androidPlugin.requestNotificationsPermission();
  }

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
  final String title =
      message.notification?.title ??
      message.data['title'] ??
      'Notification';
  final String body =
      message.notification?.body ??
      message.data['body'] ??
      '';

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    defaultNotificationChannel.id,
    defaultNotificationChannel.name,
    channelDescription: defaultNotificationChannel.description,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    icon: '@mipmap/ic_launcher',
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  final int id = message.messageId != null
      ? message.messageId.hashCode.abs()
      : DateTime.now().millisecondsSinceEpoch.remainder(100000);

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
    payload: message.data['payload'] ?? message.data.toString(),
  );
}

// ------------------------ FCM Initialization ------------------------
Future<void> initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize local notifications and channels
  await initLocalNotifications();

  // Request permissions for notifications (iOS & Web)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Enable foreground notification presentation on iOS
  await messaging.setForegroundNotificationPresentationOptions(
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

  // Foreground messages listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📥 Foreground notification received: ${message.notification?.title ?? message.data['title']}");
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
  final url = '$_baseUrl/utils/register_device_token/';

  await ApiClient.post(
    Uri.parse(url),
    body: {'device_token': token},
    tag: 'FCM-RegisterDeviceToken',
  );
}

// ------------------------ Unregister Token ------------------------
Future<void> unregisterFCM() async {
  const String _baseUrl = AppConstants.baseUrl;
  final String? token = GetStorage().read<String>('FCMToken');

  if (token == null) return;

  final url = '$_baseUrl/notification/unregister_device_token/';

  await ApiClient.post(
    Uri.parse(url),
    body: {'token': token},
    tag: 'FCM-UnregisterDeviceToken',
  );
}
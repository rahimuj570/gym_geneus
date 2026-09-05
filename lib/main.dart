import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kenzeno/app/modules/home/controllers/searchcontroller.dart';
import 'package:toastification/toastification.dart';

import 'app/modules/workout/views/excercisedetails.dart';
import 'firebase_options.dart';

import 'app/modules/auth/controllers/authcontroller.dart';
import 'app/modules/home/controllers/calender_controller.dart';
import 'app/modules/home/controllers/navcontroller.dart';
import 'app/modules/home/service/home_service.dart';
import 'app/modules/nutrition/controllers/nutri_controller.dart';
import 'app/modules/onboard/controllers/onboard_controller.dart';
import 'app/modules/onboard/views/splashview.dart';
import 'app/modules/setup/controllers/bottomsheetcontroller.dart';
import 'app/modules/setup/controllers/schedule_controller.dart';
import 'app/modules/setup/controllers/setup_controller.dart';
import 'app/modules/setup/service/service.dart';
import 'app/modules/setting/controller/profilecontroller.dart';
import 'app/modules/setting/controller/setting_controller.dart';
import 'app/modules/setting/service/setting_service.dart';
import 'app/modules/subscription/controllers/subscription_controller.dart';
import 'app/modules/workout/controllers/workoutcontroller.dart';
import 'app/modules/workout/services/workout_services.dart';
import 'app/res/colors/colors.dart';

// Global instance for local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in background
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 Background message handled: ${message.messageId}');
  // Add your notification handling logic here if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load .env file (secrets like RevenueCat key)
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env loaded successfully');
  } catch (e) {
    print('❌ Failed to load .env: $e');
    // Continue anyway (you can add fallback keys if needed)
  }

  // 2. Initialize Firebase (critical for firebase_messaging, etc.)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase init failed: $e');
  }

  // 3. Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tapped logic here
      print('Notification tapped: ${response.payload}');
    },
  );
  // 5. Other initializations
  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscriptionController(), fenix: true);
    Get.lazyPut(() => SetupService(), fenix: true);
    Get.lazyPut(() => HomeService(), fenix: true);
    Get.lazyPut(() => SearchController(), fenix: true);
    Get.lazyPut(() => SearchController2(), fenix: true);
    Get.lazyPut(() => OnboardController(), fenix: true);
    Get.lazyPut(() => NutritionController(), fenix: true);
    Get.lazyPut(() => BottomSheetController(), fenix: true);
    Get.lazyPut(() => SetupController(), fenix: true);
    Get.put(Authcontroller());
    Get.lazyPut(() => GalleryController(), fenix: true);
    Get.lazyPut(() => NavController(), fenix: true);
    Get.lazyPut(() => ScheduleController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => WorkoutService(), fenix: true);
    Get.lazyPut(() => WorkoutController(), fenix: true);
    Get.put(VideoCleanupHelper(), permanent: true);
    Get.lazyPut(() => SettingService(), fenix: true);
    Get.lazyPut(() => Settingcontroller(), fenix: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: (fontSize, instance) {
        if (instance.screenWidth >= 600) {
          return fontSize * 1.15;
        }
        return FontSizeResolvers.radius(fontSize, instance);
      },
      builder: (context, child) {
        debugPrint('ScreenUtil scaleWidth: ${ScreenUtil().scaleWidth}');
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: ToastificationWrapper(
            child: GetMaterialApp(
              initialBinding: InitialBinding(),
              debugShowCheckedModeBanner: false,
              title: "Kenzeno",
              theme: ThemeData(
                scaffoldBackgroundColor: AppColor.black111214,
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: AppColor.black111214,
                  scrolledUnderElevation: 0,
                ),
              ),
              home: const SplashView(),
            ),
          ),
        );
      },
    );
  }
}

// lib/controllers/subscription_controller.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kenzeno/app/constants/appconstants.dart';
import 'package:kenzeno/app/modules/setting/views/privacy_policy.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';

class SubscriptionPlanItem {
  final String id;
  final String duration; // 'MONTHLY' or 'YEARLY'
  final String price; // '$9.99' or '$59.99'
  final String monthlyPrice; // '$9.99' or '$4.99'
  final List<String> features;
  final bool isBestValue;
  final String? trialText;
  final Package? package;

  SubscriptionPlanItem({
    required this.id,
    required this.duration,
    required this.price,
    required this.monthlyPrice,
    required this.features,
    this.isBestValue = false,
    this.trialText,
    this.package,
  });
}

class SubscriptionController extends GetxController {
  /// Observables for UI
  final isLoading = false.obs;
  final isSubscribed = false.obs;
  final activePlan = 'free'.obs; // 'free', 'monthly', 'yearly', 'trial'

  /// Parsed plans for UI display
  final availablePlans = <SubscriptionPlanItem>[].obs;

  Offerings? currentOfferings;

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    isSubscribed.value = box.read<bool>('is_subscribed') ?? false;
    activePlan.value = box.read<String>('active_plan') ?? 'free';
    availablePlans.assignAll(_getDefaultPlans());
    _initRevenueCat();
  }

  List<SubscriptionPlanItem> _getDefaultPlans() {
    return [
      SubscriptionPlanItem(
        id: 'monthly',
        duration: 'MONTHLY',
        price: '\$9.99',
        monthlyPrice: '\$9.99',
        features: const [
          'Body Scan & Analysis',
          'Custom Workouts & Plans',
          'Progress Tracking',
          'Nutrition Plan',
          'Achievements & More',
        ],
        isBestValue: false,
        trialText: '7-day free trial',
      ),
      SubscriptionPlanItem(
        id: 'yearly',
        duration: 'YEARLY',
        price: '\$59.99',
        monthlyPrice: '\$4.99',
        features: const [
          'Body Scan & Analysis',
          'Custom Workouts & Plans',
          'Progress Tracking',
          'Nutrition Plan',
          'Achievements & More',
        ],
        isBestValue: true,
        trialText: '7-day free trial',
      ),
    ];
  }

  Future<void> _initRevenueCat() async {
    try {
      if (GetPlatform.isWeb || GetPlatform.isWindows || GetPlatform.isLinux) {
        print("ℹ️ RevenueCat mobile billing skipped on desktop/web.");
        availablePlans.assignAll(_getDefaultPlans());
        isLoading.value = false;
        return;
      }

      final appleKey =
          dotenv.env['REVENUECAT_APPLE_PUBLIC_KEY'] ??
          'appl_yYoLjFEpMdLLrNXuRnIzJHPqLNO';
      final googleKey =
          dotenv.env['REVENUECAT_GOOGLE_PUBLIC_KEY'] ??
          'goog_jdEwpzQbkTOdwlEHFUtESByudGf';
      final testKey =
          dotenv.env['REVENUECAT_TEST_PUBLIC_KEY'] ??
          'test_NvNhmyLkEIisARtCdrQnSsPBywT';

      String apiKey = GetPlatform.isAndroid ? googleKey : appleKey;
      if (apiKey.isEmpty || apiKey.contains('placeholder')) {
        apiKey = testKey;
      }

      await Purchases.setLogLevel(LogLevel.debug);

      try {
        await Purchases.configure(
          PurchasesConfiguration(apiKey)..appUserID = null,
        );
      } catch (e) {
        print(
          "⚠️ Billing init with primary key failed ($e). Falling back to RevenueCat Test Store Key...",
        );
        await Purchases.configure(
          PurchasesConfiguration(testKey)..appUserID = null,
        );
      }

      Purchases.addCustomerInfoUpdateListener(_handleCustomerUpdate);

      await _refreshCustomerInfo();
      await _fetchOfferings();
    } catch (e) {
      print("RevenueCat init failed: $e. Using fallback plans.");
      availablePlans.assignAll(_getDefaultPlans());
      isLoading.value = false;
    }
  }

  Future<void> _refreshCustomerInfo() async {
    try {
      final box = GetStorage();
      final userEmail =
          box.read<String>('registered_email') ?? box.read<String>('userEmail');
      if (userEmail != null && userEmail.isNotEmpty) {
        await Purchases.logIn(userEmail);
      }
      final customerInfo = await Purchases.getCustomerInfo();
      _updateEntitlement(customerInfo);
    } catch (e) {
      print("Refresh customer info error: $e");
    }
  }

  void _handleCustomerUpdate(CustomerInfo info) {
    _updateEntitlement(info);
    if (isSubscribed.value) {}
  }

  Future<void> _fetchOfferings() async {
    try {
      isLoading.value = true;

      final testKey =
          dotenv.env['REVENUECAT_TEST_PUBLIC_KEY'] ??
          'test_NvNhmyLkEIisARtCdrQnSsPBywT';

      try {
        currentOfferings = await Purchases.getOfferings();
        print("✅ Primary Key getOfferings returned successfully.");
        _logOfferingsDetails(currentOfferings);
      } catch (e) {
        print("⚠️ RevenueCat getOfferings error with primary key: $e");
        if (e.toString().contains('BILLING_UNAVAILABLE') ||
            e.toString().contains('PurchaseNotAllowedError')) {
          print(
            "🔄 Billing unavailable on device. Retrying with RevenueCat Test Store Key ($testKey)...",
          );
          await Purchases.configure(
            PurchasesConfiguration(testKey)..appUserID = null,
          );
          currentOfferings = await Purchases.getOfferings();
          _logOfferingsDetails(currentOfferings);
        } else {
          rethrow;
        }
      }

      List<Package> packages =
          currentOfferings?.current?.availablePackages ?? [];

      if (packages.isEmpty && currentOfferings?.all.isNotEmpty == true) {
        packages = currentOfferings!.all.values.first.availablePackages;
      }

      if (packages.isEmpty) {
        print(
          "🔄 Primary key returned 0 packages. Trying RevenueCat Test Store Key ($testKey)...",
        );
        try {
          await Purchases.configure(
            PurchasesConfiguration(testKey)..appUserID = null,
          );
          currentOfferings = await Purchases.getOfferings();
          _logOfferingsDetails(currentOfferings);
          packages = currentOfferings?.current?.availablePackages ?? [];
          if (packages.isEmpty && currentOfferings?.all.isNotEmpty == true) {
            packages = currentOfferings!.all.values.first.availablePackages;
          }
        } catch (e) {
          print("Test store key config error: $e");
        }
      }

      if (packages.isNotEmpty) {
        availablePlans.assignAll(
          packages.map((pkg) {
            final product = pkg.storeProduct;
            final isYearly =
                product.identifier.toLowerCase().contains('yearly') ||
                pkg.identifier.toLowerCase().contains('annual') ||
                product.title.toLowerCase().contains('year') ||
                product.subscriptionPeriod?.contains('P1Y') == true;

            final monthlyEquivalent = isYearly
                ? '\$${(product.price / 12).toStringAsFixed(2)}'
                : product.priceString;

            String trialText = '';
            final options = product.subscriptionOptions;
            if (options != null && options.isNotEmpty) {
              final trialOption = options.firstWhere(
                (opt) => opt.freePhase != null,
                orElse: () => options.first,
              );

              final freePhase = trialOption.freePhase;
              if (freePhase != null && freePhase.price.amountMicros == 0) {
                trialText = '7-day free trial';
              }
            }

            return SubscriptionPlanItem(
              id: pkg.identifier,
              duration: isYearly ? 'YEARLY' : 'MONTHLY',
              price: product.priceString,
              monthlyPrice: monthlyEquivalent,
              features: const [
                'Body Scan & Analysis',
                'Custom Workouts & Plans',
                'Progress Tracking',
                'Nutrition Plan',
                'Achievements & More',
              ],
              isBestValue: isYearly,
              trialText: trialText.isNotEmpty ? trialText : '7-day free trial',
              package: pkg,
            );
          }).toList(),
        );
      } else {
        print("⚠️ No packages found from RevenueCat. Using fallback plans.");
        availablePlans.assignAll(_getDefaultPlans());
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print("Fetch offerings error: $e. Using fallback plans.");
      availablePlans.assignAll(_getDefaultPlans());
    }
  }

  /// Call this when user wants to refresh plans (e.g. pull-to-refresh)
  Future<void> refreshOfferings() => _fetchOfferings();

  /// Helper to activate test subscription when Play Store items are draft or unavailable
  void _activateTestSubscription(String duration) {
    isSubscribed.value = true;
    activePlan.value =
        duration.toLowerCase().contains('year') ? 'yearly' : 'monthly';

    final box = GetStorage();
    box.write('is_subscribed', true);
    box.write('active_plan', activePlan.value);

    toastification.show(
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      primaryColor: Colors.orange,
      foregroundColor: Colors.white,
      title: Text(
        'Test Mode Activated',
        style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
      ),
      description: Text(
        'Play Store item pending activation. Test subscription activated!',
        style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
    Get.offAll(() => Navbar(), transition: Transition.rightToLeft);
  }

  /// Purchase plan (handles live RevenueCat store purchases with dev test fallback)
  Future<void> purchasePlan(SubscriptionPlanItem planItem) async {
    if (planItem.package == null) {
      try {
        isLoading.value = true;
        await _fetchOfferings();
        isLoading.value = false;

        final updatedPlan = availablePlans.firstWhere(
          (p) => p.duration == planItem.duration && p.package != null,
          orElse: () => planItem,
        );

        if (updatedPlan.package != null) {
          await purchasePackage(updatedPlan.package!);
          return;
        }

        _activateTestSubscription(planItem.duration);
        return;
      } catch (e) {
        isLoading.value = false;
        _activateTestSubscription(planItem.duration);
        return;
      }
    }

    await purchasePackage(planItem.package!);
  }

  /// Purchase a package (Monthly / Yearly) via RevenueCat SDK
  Future<void> purchasePackage(Package package) async {
    try {
      isLoading.value = true;

      final purchaseParams = PurchaseParams.package(package);

      final PurchaseResult purchaseResult = await Purchases.purchase(
        purchaseParams,
      );

      final CustomerInfo customerInfo = purchaseResult.customerInfo;
      _updateEntitlement(customerInfo);

      isLoading.value = false;

      if (isSubscribed.value) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            'Success',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'Subscription activated!',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        Get.offAll(() => Navbar(), transition: Transition.rightToLeft);
      }
    } catch (e) {
      isLoading.value = false;
      print("Purchase error: $e");

      final errStr = e.toString().toLowerCase();
      final isItemUnavailable =
          errStr.contains('not available for purchase') ||
          errStr.contains('productnotavailableforpurchaseerror') ||
          errStr.contains('could not be found') ||
          errStr.contains('item_unavailable') ||
          errStr.contains('item_not_found') ||
          errStr.contains('attempting') ||
          errStr.contains('store_problem') ||
          errStr.contains('billing_unavailable') ||
          errStr.contains('item not found');

      if (isItemUnavailable) {
        _activateTestSubscription(package.identifier);
        return;
      }

      if (!errStr.contains('usercancelledexception') &&
          !errStr.contains('purchasecancellederror')) {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            'Purchase Error',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'Subscription purchase could not be completed.',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }
    }
  }

  /// Restore purchases button
  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      final customerInfo = await Purchases.restorePurchases();
      _updateEntitlement(customerInfo);
      isLoading.value = false;
      if (isSubscribed.value) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            'Success',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'Purchases restored!',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      } else {
        toastification.show(
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          primaryColor: AppColor.green16A34A,
          foregroundColor: Colors.white,
          title: Text(
            'Info',
            style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
          ),
          description: Text(
            'No active subscription found',
            style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
      }
    } catch (e) {
      isLoading.value = false;
      print("Restore error: $e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          'Error',
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          'Restore failed',
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    }
  }

  /// Open Terms of Use (EULA)
  Future<void> openEula() async {
    final Uri url = Uri.parse(AppConstants.eulaUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print('Could not launch EULA URL: $url');
      }
    } catch (e) {
      print('Error launching EULA URL: $e');
    }
  }

  /// Open Privacy Policy
  Future<void> openPrivacyPolicy() async {
    try {
      Get.to(() => const PrivacyPolicyScreen());
    } catch (e) {
      final Uri url = Uri.parse(AppConstants.privacyPolicyUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print('Could not launch Privacy Policy URL: $url');
      }
    }
  }

  /// Private: update UI state from customer info
  void _updateEntitlement(CustomerInfo info) {
    final hasActiveEntitlement = info.entitlements.active.isNotEmpty;
    final proEntitlement =
        info.entitlements.all['pro'] ??
        info.entitlements.all['Pro'] ??
        info.entitlements.all['premium'] ??
        info.entitlements.all['Premium'];

    isSubscribed.value =
        hasActiveEntitlement || (proEntitlement?.isActive ?? false);

    if (isSubscribed.value) {
      final activeEnt = info.entitlements.active.values.isNotEmpty
          ? info.entitlements.active.values.first
          : proEntitlement;

      if (activeEnt?.periodType == PeriodType.trial) {
        activePlan.value = 'trial';
      } else {
        final pid = (activeEnt?.productIdentifier ?? '').toLowerCase();
        if (pid.contains('year') || pid.contains('annual')) {
          activePlan.value = 'yearly';
        } else {
          activePlan.value = 'monthly';
        }
      }
    } else {
      activePlan.value = 'free';
    }

    final box = GetStorage();
    box.write('is_subscribed', isSubscribed.value);
    box.write('active_plan', activePlan.value);
  }

  /// Log in specific user to RevenueCat
  Future<void> logInUser(String email) async {
    try {
      if (email.isNotEmpty &&
          !GetPlatform.isWeb &&
          !GetPlatform.isWindows &&
          !GetPlatform.isLinux) {
        final res = await Purchases.logIn(email);
        _updateEntitlement(res.customerInfo);
      }
    } catch (e) {
      print("RevenueCat logIn error: $e");
    }
  }

  /// Log out user from RevenueCat
  Future<void> logOutUser() async {
    try {
      if (!GetPlatform.isWeb &&
          !GetPlatform.isWindows &&
          !GetPlatform.isLinux) {
        final customerInfo = await Purchases.logOut();
        _updateEntitlement(customerInfo);
      }
    } catch (e) {
      print("RevenueCat logOut error: $e");
    }
  }

  /// Status text for UI (e.g. "Free Trial • Ends 2026-03-06")
  String getStatusText() {
    if (!isSubscribed.value) {
      return 'Start your 7-day free trial';
    }

    if (activePlan.value == 'trial') {
      return 'Free Trial active';
    }

    return 'Subscribed (${activePlan.value.capitalize})';
  }

  /// Logs all offerings, packages, and store products returned by RevenueCat
  void _logOfferingsDetails(Offerings? offerings) {
    print(
      '================ 📦 REVENUECAT OFFERINGS & PRODUCTS LOG 📦 ================',
    );
    if (offerings == null) {
      print('❌ Offerings object is NULL');
      print(
        '========================================================================',
      );
      return;
    }

    print(
      '🔹 Current Offering ID: ${offerings.current?.identifier ?? "None (No current offering set)"}',
    );

    final currentPackages = offerings.current?.availablePackages ?? [];
    print('🔹 Current Offering Package Count: ${currentPackages.length}');
    for (var pkg in currentPackages) {
      final p = pkg.storeProduct;
      print('   👉 Package ID: ${pkg.identifier} | Type: ${pkg.packageType}');
      print('      Product ID: ${p.identifier} | Title: "${p.title}"');
      print('      Price: ${p.priceString} | Period: ${p.subscriptionPeriod}');
    }

    print('🔹 Total Offerings in Dashboard: ${offerings.all.length}');
    offerings.all.forEach((offeringId, offering) {
      print(
        '   📁 Offering ID: $offeringId (Packages: ${offering.availablePackages.length})',
      );
      for (var pkg in offering.availablePackages) {
        final p = pkg.storeProduct;
        print(
          '      - Package ID: ${pkg.identifier} | Product ID: ${p.identifier} | Price: ${p.priceString}',
        );
      }
    });
    print(
      '========================================================================',
    );
  }

  @override
  void onClose() {
    // Optional: remove listener if needed
    super.onClose();
  }
}

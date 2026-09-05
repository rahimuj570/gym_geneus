import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../home/views/navbar.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../../subscription/widgets/infocard.dart';
import '../../subscription/widgets/subscription_card.dart';


class sad extends StatelessWidget {
  sad({super.key});

  final SubscriptionController controller = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());

  final List<Map<String, String>> featureCards = [
    {
      'svg': ImageAssets.svg14,
      'title': 'Progress Tracking',
      'subtitle': 'Monitor your fitness journey',
    },
    {
      'svg': ImageAssets.svg15,
      'title': 'Body Scan',
      'subtitle': 'Advanced body analysis',
    },
    {
      'svg': ImageAssets.svg13,
      'title': 'Custom Workout',
      'subtitle': 'Personalized training plans',
    },
    {
      'svg': ImageAssets.svg16,
      'title': 'Achievements',
      'subtitle': 'Unlock fitness milestones',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            ImageAssets.img_15,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final statusText = controller.getStatusText();

              // Already subscribed screen
              if (controller.isSubscribed.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 80.r),
                      SizedBox(height: 24.h),
                      Text(
                        "You're All Set!",
                        style: AppTextStyles.poppinsBold.copyWith(
                          fontSize: 28.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        statusText,
                        style: AppTextStyles.poppinsRegular.copyWith(
                          fontSize: 16.sp,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40.h),
                      CustomButton(
                        onPress: () async => Get.to(
                          () => Navbar(),
                          transition: Transition.rightToLeft,
                        ),
                        title: 'CONTINUE TO APP',
                        buttonColor: Colors.white,
                        textColor: AppColor.customPurple,
                        borderColor: AppColor.customPurple,
                        radius: 12.r,
                        height: 60.h,
                        width: 280.w,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                );
              }

              // Not subscribed → paywall
              final packages =
                  controller.currentOfferings?.current?.availablePackages ?? [];

              if (packages.isEmpty) {
                return Center(
                  child: Text(
                    'No subscription plans available\nPull to refresh',
                    style: AppTextStyles.poppinsRegular.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),

                    // Logo / icon
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SvgPicture.asset(ImageAssets.svg13, height: 36.h),
                    ),

                    SizedBox(height: 16.h),

                    // Main titles
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        "CHANGE YOUR LIFE TODAY",
                        style: AppTextStyles.poppinsBold.copyWith(
                          fontSize: 24.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "INVEST IN YOUR FUTURE",
                      style: AppTextStyles.poppinsBold.copyWith(
                        fontSize: 24.sp,
                        color: AppColor.customPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        "Get full access to workouts, body scan, progress tracking & nutrition plans",
                        style: AppTextStyles.poppinsRegular.copyWith(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Dynamic Carousel from RevenueCat
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 340.h,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          viewportFraction: 0.82,
                          padEnds: false,
                        ),
                        items: packages.map((pkg) {
                          final product = pkg.storeProduct;
                          final isYearly =
                              product.title.toLowerCase().contains('year') ||
                              pkg.identifier.contains('annual') ||
                              product.subscriptionPeriod?.contains('P1Y') ==
                                  true;

                          final monthlyEquivalent = isYearly
                              ? '\$${(product.price / 12).toStringAsFixed(2)}/mo'
                              : product.priceString;

                          // ────────────────────────────────────────────────
                          // Trial text detection – using available fields only
                          String trialText = '';

                          final options = product.subscriptionOptions;
                          if (options != null && options.isNotEmpty) {
                            final trialOption = options.firstWhere(
                              (opt) => opt.freePhase != null,
                              orElse: () => options.first,
                            );

                            final freePhase = trialOption.freePhase;

                            if (freePhase != null && freePhase.price.amountMicros == 0) {
                              // In 9.12.3: duration fields are not public → hardcode your configured trial
                              // Change '7-day' if your actual trial is different (e.g. 3-day, 14-day)
                              trialText = '7-day free trial';

                              // Optional: If you added custom metadata in RevenueCat dashboard
                              // trialText = pkg.metadata['trial_duration']?.toString() ?? '7-day free trial';
                            }
                          }
                          // ────────────────────────────────────────────────

                          return SubscriptionCard(
                            duration: isYearly ? 'YEARLY' : 'MONTHLY',
                            price: product.priceString,
                            monthlyPrice: monthlyEquivalent,
                            features: [
                              'Body Scan & Analysis',
                              'Custom Workouts & Plans',
                              'Progress Tracking',
                              'Nutrition Plan',
                              'Achievements & More',
                            ],
                            isBestValue: isYearly,
                            trialText: trialText.isNotEmpty ? trialText : null,
                            onPressed: () => controller.purchasePackage(pkg),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Feature grid
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: featureCards.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 12.w,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final card = featureCards[index];
                          return InfoCard(
                            svgPath: card['svg']!,
                            title: card['title']!,
                            subtitle: card['subtitle']!,
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: InfoCard(
                        svgPath: ImageAssets.svg17,
                        title: "Nutrition Plan",
                        subtitle: "Calorie tracking + diet/food intake",
                      ),
                    ),

                    SizedBox(height: 60.h),

                    // Bottom action bar
                    Container(
                      width: double.infinity,
                      color: AppColor.customPurple,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          Text(
                            statusText,
                            style: AppTextStyles.poppinsMedium.copyWith(
                              color: Colors.white,
                              fontSize: 15.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          CustomButton(
                            onPress: () async => Get.to(
                              () => Navbar(),
                              transition: Transition.rightToLeft,
                            ),
                            title: 'CONTINUE • UNLOCK FULL ACCESS',
                            buttonColor: Colors.white,
                            textColor: AppColor.customPurple,
                            borderColor: AppColor.customPurple,
                            radius: 12.r,
                            height: 60.h,
                            width: double.infinity,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Cancel anytime • Secure payment',
                                style: AppTextStyles.poppinsRegular.copyWith(
                                  color: AppColor.purpleCCC2FF,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              TextButton(
                                onPressed: controller.restorePurchases,
                                child: Text(
                                  'Restore Purchases',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

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

import '../controllers/subscription_controller.dart';
import '../widgets/infocard.dart';
import '../widgets/subscription_card.dart';

class Subscription extends StatelessWidget {
  Subscription({super.key});

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Get.offAll(() => Navbar());
            },
          ),
        ],
      ),
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
                        onPress: () async => Get.offAll(
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
              final plans = controller.availablePlans;

              if (plans.isEmpty) {
                return RefreshIndicator(
                  color: AppColor.customPurple,
                  backgroundColor: Colors.white,
                  onRefresh: controller.refreshOfferings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 150.h,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white54,
                                size: 60.sp,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No subscription plans available\nPull to refresh',
                                style: AppTextStyles.poppinsRegular.copyWith(
                                  fontSize: 16.sp,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 30.h),
                              CustomButton(
                                onPress: () async {
                                  Get.offAll(
                                    () => Navbar(),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                title: 'CONTINUE TO APP',
                                buttonColor: Colors.white,
                                textColor: AppColor.customPurple,
                                borderColor: AppColor.customPurple,
                                radius: 12.r,
                                height: 50.h,
                                width: 220.w,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColor.customPurple,
                backgroundColor: Colors.white,
                onRefresh: controller.refreshOfferings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                      // Dynamic Carousel
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
                          items: plans.map((planItem) {
                            return SubscriptionCard(
                              duration: planItem.duration,
                              price: planItem.price,
                              monthlyPrice: planItem.monthlyPrice,
                              features: planItem.features,
                              isBestValue: planItem.isBestValue,
                              trialText: planItem.trialText,
                              onPressed: () => controller.purchasePlan(planItem),
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
                            crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 3 : 2,
                            mainAxisSpacing: 16.h,
                            crossAxisSpacing: 12.w,
                            childAspectRatio: MediaQuery.of(context).size.width >= 600 ? 1.1 : 0.95,
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
                              onPress: () async {
                                if (plans.isNotEmpty) {
                                  final planToPurchase = plans.firstWhere(
                                    (p) => p.isBestValue,
                                    orElse: () => plans.first,
                                  );
                                  await controller.purchasePlan(planToPurchase);
                                } else {
                                  Get.offAll(
                                    () => Navbar(),
                                    transition: Transition.rightToLeft,
                                  );
                                }
                              },
                              title: 'SUBSCRIBE NOW • START FREE TRIAL',
                              buttonColor: Colors.white,
                              textColor: AppColor.customPurple,
                              borderColor: AppColor.customPurple,
                              radius: 12.r,
                              height: 60.h,
                              width: double.infinity,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
                              style: AppTextStyles.poppinsRegular.copyWith(
                                color: AppColor.purpleCCC2FF,
                                fontSize: 11.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                InkWell(
                                  onTap: controller.openEula,
                                  child: Text(
                                    'Terms of Use (EULA)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: AppColor.purpleCCC2FF,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                InkWell(
                                  onTap: controller.openPrivacyPolicy,
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: AppColor.purpleCCC2FF,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                InkWell(
                                  onTap: controller.restorePurchases,
                                  child: Text(
                                    'Restore Purchases',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
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
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


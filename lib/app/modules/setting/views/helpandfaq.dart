// lib/app/modules/help/views/help_and_faqs_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controller/faq_controller.dart';
import 'package:toastification/toastification.dart';
import 'package:kenzeno/app/res/fonts/textstyle.dart';
import 'package:kenzeno/app/res/colors/colors.dart';

class HelpAndFaqsPage extends StatelessWidget {
  const HelpAndFaqsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FAQController controller = Get.put(FAQController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColor.black111214,
        appBar: AppBar(
          backgroundColor: AppColor.black111214,
          elevation: 0,
          leading: const BackButtonBox(),
          title: Text(
            'Help & FAQs',
            style: AppTextStyles.poppinsBold.copyWith(
              color: AppColor.white,
              fontSize: 22.sp,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                'How Can We Help You?',
                style: AppTextStyles.poppinsMedium.copyWith(
                  color: AppColor.white,
                  fontSize: 18.sp,
                ),
              ),
            ),

            // Primary Tabs
            // PRIMARY TAB BAR (FAQ / Contact Us)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Container(
                height: 45.h,
                decoration: BoxDecoration(
                  color: AppColor.black111214,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.gray374151),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColor.customPurple,
                  ),
                  labelColor:
                      AppColor.black111214, // active text color (same as inner)
                  unselectedLabelColor: AppColor.white.withOpacity(0.7),
                  labelStyle: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 15.sp,
                  ),
                  unselectedLabelStyle: AppTextStyles.poppinsMedium.copyWith(
                    fontSize: 15.sp,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'FAQ'),
                    Tab(text: 'Contact Us'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  FAQView(controller: controller),
                  ContactUsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQView extends StatelessWidget {
  final FAQController controller;
  const FAQView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // INNER TAB BAR
        Container(
          height: 40.h,
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.black111214,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColor.gray374151),
          ),
          child: TabBar(
            controller: controller.tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColor.customPurple,
            ),
            labelColor: AppColor.black111214,
            unselectedLabelColor: AppColor.white.withOpacity(0.7),
            labelStyle: AppTextStyles.poppinsBold.copyWith(fontSize: 14.sp),
            unselectedLabelStyle: AppTextStyles.poppinsMedium.copyWith(
              fontSize: 14.sp,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Account'),
              Tab(text: 'Services'),
            ],
          ),
        ),

        // FAQ LIST
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.customPurple),
              );
            }

            final list = controller.filteredFAQs;

            if (list.isEmpty) {
              return Center(
                child: Text(
                  'No FAQs available',
                  style: TextStyle(color: AppColor.gray9CA3AF, fontSize: 16.sp),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final faq = list[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Theme(
                    data: ThemeData(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      collapsedIconColor: AppColor.white.withOpacity(0.7),
                      iconColor: AppColor.customPurple,
                      title: Text(
                        faq.question,
                        style: AppTextStyles.poppinsMedium.copyWith(
                          color: AppColor.white,
                          fontSize: 16.sp,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 12.h,
                            left: 4.w,
                            right: 4.w,
                          ),
                          child: Text(
                            faq.answer,
                            style: AppTextStyles.poppinsRegular.copyWith(
                              color: AppColor.gray9CA3AF,
                              fontSize: 14.sp,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// Replace your ContactUsView with this (everything else stays the same)

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FAQController>();

    return Obx(() {
      if (controller.isContactLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColor.customPurple),
        );
      }

      if (controller.contactOptions.isEmpty) {
        return Center(
          child: Text(
            'No contact options available',
            style: TextStyle(color: AppColor.gray9CA3AF, fontSize: 16.sp),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: controller.contactOptions.length,
        itemBuilder: (context, i) {
          final item = controller.contactOptions[i];

          return ExpansionTile(
            collapsedIconColor: AppColor.white,
            iconColor: AppColor.customPurple,
            title: Row(
              children: [
                // Load icon from URL
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    item.icon,
                    width: 32.w,
                    height: 32.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.link,
                      color: AppColor.customPurple,
                      size: 28.sp,
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Text(
                  item.name,
                  style: AppTextStyles.poppinsMedium.copyWith(
                    color: AppColor.white,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: GestureDetector(
                  onTap: () {
                    // You can use url_launcher here if you want
                    // For now just show the link
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.fillColored,
                      primaryColor: AppColor.green16A34A,
                      foregroundColor: Colors.white,
                      title: Text(
                        "Opening",
                        style: AppTextStyles.poppinsBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      description: Text(
                        item.link,
                        style: AppTextStyles.poppinsRegular.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 4),
                      borderRadius: BorderRadius.circular(12),
                      showProgressBar: true,
                    );
                  },
                  child: Text(
                    item.link,
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.customPurple,
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

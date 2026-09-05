// my_profile_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kenzeno/app/res/assets/asset.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/textfield.dart';
import '../../setup/controllers/bottomsheetcontroller.dart';
import '../controller/profilecontroller.dart';
import '../model/profile_model.dart';
import 'dart:io';

class MyProfileEditScreen extends StatelessWidget {
  MyProfileEditScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();
  final BottomSheetController imageController = Get.find<BottomSheetController>();

  // Rank SVG mapping
  final Map<String, String> rankIcons = {
    'BRONZE': ImageAssets.svg64,
    'SILVER': ImageAssets.svg65,
    'GOLD': ImageAssets.svg66,
    'PLATINUM': ImageAssets.svg67,
    'DIAMOND': ImageAssets.svg68,
  };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonBox(),
        title: Text(
          "My Profile",
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.customPurple),
          );
        }

        final profile = controller.profile.value;


        return Column(
          children: [
            SizedBox(height: 10.h),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(() {
                        // Check if a new image was picked via BottomSheetController
                        final pickedFile = imageController.pickedImage.value;
                        
                        return CircleAvatar(
                          radius: 45.r,
                          backgroundImage: pickedFile != null
                              ? FileImage(pickedFile)
                              : (profile.avatar != null && profile.avatar!.isNotEmpty
                                  ? NetworkImage(profile.avatar!)
                                  : const AssetImage(ImageAssets.img_3)) as ImageProvider,
                          backgroundColor: AppColor.gray9CA3AF,
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => imageController.getBottomSheet(),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.black111214,
                                width: 2.w,
                              ),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: AppColor.customPurple,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Full Name
                  Text(
                    controller.fullNameController.text.isEmpty
                        ? "Your Name"
                        : controller.fullNameController.text,
                    style: AppTextStyles.poppinsSemiBold.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),

                  // Email
                  Text(
                    profile?.email ?? 'your@email.com',
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.white30,
                      fontSize: 14.sp,
                    ),
                  ),

                  // Birthday
                  Text(
                    (controller.dobController.text.isEmpty ||
                            controller.dobController.text == DateTime.now().toIso8601String().split('T').first)
                        ? "Birthday: Not set"
                        : "Birthday: ${_formatBirthday(controller.dobController.text)}",
                    style: AppTextStyles.poppinsRegular.copyWith(
                      color: AppColor.purpleCCC2FF,
                      fontSize: 14.sp,
                    ),
                  ),

                  // Rank badge (beautiful + with level)
                  if (profile.rank != null) ...[
                    SizedBox(height: 8.h),
                    _buildRankBadge(profile),
                  ],
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),

                    // Stats row
                    _buildStatsRow(
                      weight: profile.weightKg?.toStringAsFixed(1) ?? '0',
                      height: profile.heightCm?.toStringAsFixed(1) ?? '0',
                      age: controller.effectiveAge,
                    ),

                    // Input Fields
                    _buildInputField(
                      label: 'Full Name',
                      controller: controller.fullNameController,
                      hintText: 'Enter your full name',
                    ),
                    _buildInputField(
                      label: 'Email',
                      controller: controller.emailController,
                      hintText: 'your@email.com',
                      readOnly: true,
                    ),
                    _buildInputField(
                      label: 'Mobile Number',
                      controller: controller.mobileController,
                      hintText: '+123 456 7890',
                    ),
                    _buildGenderDropdown(),
                    _buildInputField(
                      label: 'Date of Birth',
                      controller: controller.dobController,
                      hintText: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: () async {
                        DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 20));
                        if (controller.dobController.text.isNotEmpty) {
                          try {
                            initialDate = DateTime.parse(controller.dobController.text.trim());
                          } catch (_) {}
                        }
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColor.customPurple,
                                  onPrimary: Colors.white,
                                  surface: AppColor.gray1F2937,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
                          controller.dobController.text = formattedDate;
                          controller.update();
                        }
                      },
                    ),
                    _buildInputField(
                      label: 'Weight',
                      controller: controller.weightController,
                      hintText: 'e.g. 70.5',
                      suffixText: 'Kg',
                    ),
                    _buildInputField(
                      label: 'Height',
                      controller: controller.heightController,
                      hintText: 'e.g. 175.0',
                      suffixText: 'CM',
                    ),

                    SizedBox(height: 30.h),

                    // Update Button
                    CustomButton(
                      onPress: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.updateProfile(
                                fullName: controller.fullNameController.text.trim().isEmpty
                                    ? null
                                    : controller.fullNameController.text.trim(),
                                phoneNumber: controller.mobileController.text.trim().isEmpty
                                    ? null
                                    : controller.mobileController.text.trim(),
                                dateOfBirth: controller.dobController.text.trim().isEmpty
                                    ? null
                                    : controller.dobController.text.trim(),
                                age: controller.effectiveAge,
                                gender: controller.selectedGender.value?.toLowerCase(),
                                heightCm: double.tryParse(
                                  controller.heightController.text.trim(),
                                ),
                                weightKg: double.tryParse(
                                  controller.weightController.text.trim(),
                                ),
                                avatar: imageController.pickedImage.value?.path,
                              );
                            },
                      title: controller.isLoading.value
                          ? "Updating..."
                          : "Update Profile",
                      fontSize: 14.sp,
                      height: 40.h,
                      fontFamily: 'WorkSans',
                      radius: 20.r,
                      fontWeight: FontWeight.bold,
                      textColor: AppColor.white,
                      borderColor: AppColor.customPurple,
                      buttonColor: AppColor.white15,
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Beautiful Rank Badge with gradient, glow and level
  Widget _buildRankBadge(ProfileModel profile) {
    final rank = profile.rank!;
    final color = _getRankColor(rank.colorCode);
    final name = rank.name;
    final level = rank.level;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.22), color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: color.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rank icon
          SvgPicture.asset(
            rankIcons[name.toUpperCase()] ?? ImageAssets.svg64,
            width: 20.w,
            height: 20.h,
          ),
          SizedBox(width: 6.w),

          // Rank name
          Text(
            name,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.4,
            ),
          ),

          SizedBox(width: 8.w),

          // Level pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color.withOpacity(0.8), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 13.sp,
                  color: AppColor.vividAmber,
                ),
                SizedBox(width: 3.w),
                Text(
                  "Lv $level",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gender dropdown
  Widget _buildGenderDropdown() {
    final genderOptions = [
      {'label': 'Male', 'value': 'male'},
      {'label': 'Female', 'value': 'female'},
      {'label': 'Other', 'value': 'other'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        Text(
          'Gender',
          style: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.customPurple,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() {
          final currentGender = controller.selectedGender.value;
          final matchedValue = (currentGender != null &&
                  genderOptions.any((g) => g['value'] == currentGender.toLowerCase()))
              ? currentGender.toLowerCase()
              : null;

          return Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.black111214),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: matchedValue,
                isExpanded: true,
                hint: Text(
                  'Select Gender',
                  style: TextStyle(
                    color: AppColor.white30,
                    fontSize: 14.sp,
                    fontFamily: 'Montserrat',
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColor.black232323,
                  size: 20.sp,
                ),
                dropdownColor: Colors.white,
                items: genderOptions.map((g) {
                  return DropdownMenuItem<String>(
                    value: g['value'],
                    child: Text(
                      g['label']!,
                      style: TextStyle(
                        color: AppColor.black232323,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedGender.value = val;
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // Input field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? suffixText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        Text(
          label,
          style: AppTextStyles.poppinsRegular.copyWith(
            color: AppColor.customPurple,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        InputTextWidget(
          onChanged: (value) {},
          onTap: onTap,
          controller: controller,
          hintText: controller.text.isEmpty ? hintText : "",
          readOnly: readOnly,
          backgroundColor: AppColor.white,
          borderColor: AppColor.black111214,
          textColor: AppColor.black232323,
          hintTextColor: AppColor.white30,
          borderRadius: 8.r,
          contentPadding: true,
          height: 40.0.h,
        ),
      ],
    );
  }

  // Stats row
  Widget _buildStatsRow({
    required String weight,
    required String height,
    required int age,
  }) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColor.customPurple,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatBox("$weight Kg", "Weight"),
            _buildVerticalDivider(),
            _buildStatBox("$age", "Years Old"),
            _buildVerticalDivider(),
            _buildStatBox("$height CM", "Height"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: AppTextStyles.poppinsSemiBold.copyWith(
          color: Colors.white,
          fontSize: 14.sp,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        label,
        style: AppTextStyles.poppinsRegular.copyWith(
          color: Colors.white,
          fontSize: 12.sp,
        ),
      ),
    ],
  );

  Widget _buildVerticalDivider() => Container(
    width: 1.w,
    height: 35.h,
    color: Colors.white.withOpacity(0.4),
    margin: EdgeInsets.symmetric(horizontal: 8.w),
  );

  // Helper: Parse rank color
  Color _getRankColor(String? hex) {
    if (hex == null) return const Color(0xFFCD7F32);
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFCD7F32);
    }
  }

  String _formatBirthday(String isoDate) {
    if (isoDate.isEmpty) return "Not set";
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    if (isoDate == todayStr) return "Not set";
    try {
      final date = DateTime.parse(isoDate);
      final day = date.day;
      final suffix = day >= 11 && day <= 13
          ? 'th'
          : {1: 'st', 2: 'nd', 3: 'rd'}[day % 10] ?? 'th';
      return "${DateFormat('MMMM').format(date)} $day$suffix";
    } catch (e) {
      return isoDate;
    }
  }
}

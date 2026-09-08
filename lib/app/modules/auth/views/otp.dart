import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/widgets/backbutton_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../../../app/widgets/custom_snackbar.dart';
import '../controllers/authcontroller.dart';
import 'reset_password.dart';

class OtpVerification extends StatefulWidget {
  final String email;
  final String fromPage;

  const OtpVerification({
    super.key,
    required this.email,
    required this.fromPage,
  });

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  late final TextEditingController otpController;
  final Authcontroller controller = Get.find<Authcontroller>();

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: BackButtonBox(),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageAssets.img_28,
                ), // replace with your background asset
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.h),

                        // Title
                        Text(
                          'OTP Verification',
                          style: AppTextStyles.workSansBold.copyWith(
                            fontSize: 25.sp,
                            color: AppColor.white,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Subtitle
                        Text(
                          'Enter the verification code we just sent to: ${widget.email}',
                          style: AppTextStyles.workSansRegular.copyWith(
                            fontSize: 14.sp,
                            color: AppColor.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 40.h),

                        // PIN Code Input
                        PinCodeTextField(
                          appContext: context,
                          keyboardType: TextInputType.number,
                          controller: otpController,
                          length: 4,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(10.r),
                            fieldHeight: 50.h,
                            fieldWidth: 60.w,
                            activeFillColor: AppColor.white,
                            selectedFillColor: AppColor.white,
                            inactiveFillColor: AppColor.white,
                            activeColor: AppColor.customPurple,
                            selectedColor: AppColor.customPurple,
                            inactiveColor: AppColor.mediumGrey,
                          ),
                          textStyle: AppTextStyles.workSansBold.copyWith(
                            color: AppColor.black111214,
                            fontSize: 18.sp,
                          ),
                          enableActiveFill: true,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          onChanged: (_) {},
                        ),
                        SizedBox(height: 40.h),

                        // Verify Button
                        Obx(
                          () => CustomButton(
                            onPress: () async {
                              final otp = otpController.text.trim();
                              if (otp.isEmpty) {
                                CustomSnackbar.showError('Please enter the verification code');
                                return;
                              }
                              if (otp.length != 4) {
                                CustomSnackbar.showError('Please enter the complete 4-digit verification code');
                                return;
                              }

                              if (widget.fromPage == "signup") {
                                controller.activateAccount(otp);
                              } else {
                                final success =
                                    await controller.verifyOtpForPasswordReset(
                                  widget.email,
                                  otp,
                                );
                                if (success) {
                                  Get.to(
                                    () => ResetPasswordView(
                                      email: widget.email,
                                      otp: otp,
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                }
                              }
                            },
                            title: 'Verify',
                            height: 40.h,
                            fontSize: 18.sp,
                            loading: controller.isLoadingverify.value,
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.w700,
                            textColor: AppColor.white,
                            borderColor: AppColor.customPurple,
                            buttonColor: AppColor.customPurple,
                            width: double.infinity,
                            radius: 20.r,
                          ),
                        ),

                        const Spacer(),

                        // Resend Link
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn’t receive code?',
                                style: AppTextStyles.workSansRegular.copyWith(
                                  color: AppColor.white.withOpacity(0.7),
                                  fontSize: 14.sp,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (!controller.isLoadingresend.value) {
                                    controller.resendOtp(email: widget.email);
                                  }
                                },
                                child: Text(
                                  ' Resend',
                                  style: AppTextStyles.workSansBold.copyWith(
                                    color: AppColor.customPurple,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ------------------------
          // Loading Overlay
          // ------------------------
          Obx(
            () => controller.isLoadingresend.value
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                      alignment: Alignment.center,
                      child: const SpinKitWave(
                        color: AppColor.customPurple,
                        size: 40,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

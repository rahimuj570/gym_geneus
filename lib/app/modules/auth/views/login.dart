import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kenzeno/app/modules/auth/controllers/authcontroller.dart';
import 'package:kenzeno/app/modules/auth/views/forgotpassword.dart';
import 'package:kenzeno/app/modules/auth/views/signup.dart';
import 'package:kenzeno/app/modules/home/views/navbar.dart';

import '../../../res/assets/asset.dart';

import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/textfield.dart';

class Login extends StatelessWidget {
  final Authcontroller controller = Get.find();
  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            ImageAssets.img_5,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    child: SvgPicture.asset(ImageAssets.svg2, height: 60.h),
                  ),
                  Text(
                    'Welcome Back!',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 25.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  // Subtitle
                  Text(
                    'Please log in to your account and start the adventure',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  // Email
                  Text(
                    'Email or Phone Number',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InputTextWidget(
                    controller: controller.emailController,
                    hintText: 'Email',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon: ImageAssets.email,
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.black111214,
                    hintTextColor: AppColor.black111214,
                    borderRadius: 20.r,
                    contentPadding: true,
                    height: 40.h,
                  ),
                  SizedBox(height: 14.h),

                  // Password
                  Text(
                    'Password',
                    style: AppTextStyles.workSansBold.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InputTextWidget(

                    controller: controller.passwordController,
                    hintText: 'Enter your password',
                    onChanged: (value) {},
                    leading: true,
                    leadingIcon: ImageAssets.svg53,
                    obscureText: true,
                    passwordIcon: ImageAssets.obsecure,
                    backgroundColor: AppColor.white,
                    borderColor: AppColor.customPurple,
                    textColor: AppColor.black111214,
                    hintTextColor: AppColor.black111214,
                    borderRadius: 20.r,
                    height: 40.h,
                  ),
                  SizedBox(height: 15.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Obx(
                        () => SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: Checkbox(
                            value: controller.ischecked.value,
                            onChanged: (value) {
                              controller.ischecked.toggle();
                            },
                            fillColor: MaterialStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(MaterialState.selected)) {
                                return AppColor.customPurple;
                              }
                              return Colors.white;
                            }),
                            checkColor: Colors.black,
                            side: const BorderSide(color: Color(0xFF404040)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Remember me",
                        style: AppTextStyles.workSansRegular.copyWith(
                          fontSize: 12.spMax,
                          color: AppColor.white,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Get.to(
                            ForgotPassword(),
                            transition: Transition.rightToLeft,
                          );
                        },
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              const LinearGradient(
                                colors: [
                                  AppColor.customPurple,
                                  AppColor.customPurple,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: Text(
                            "Forgot password?",
                            style: AppTextStyles.workSansBold.copyWith(
                              fontSize: 12.spMax,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Obx(
                    () => CustomButton(
                      onPress: () async {
                        await controller.login();
                      },

                      title: "Sign In",
                      loading: controller.isLoading.value,
                      fontSize: 16.sp,
                      height: 40.h,
                      svgorimage: true,
                      trailing: ImageAssets.svg3,
                      fontFamily: 'WorkSans',
                      radius: 20.r,
                      fontWeight: FontWeight.w700,
                      textColor: AppColor.white,
                      borderColor: AppColor.customPurple,
                      buttonColor: AppColor.customPurple,
                    ),
                  ),

                  SizedBox(height: 30.h),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Don\'t have an account?  ',
                            style: AppTextStyles.workSansRegular.copyWith(
                              color: AppColor.gray9CA3AF,
                              fontSize: 14.sp,
                            ),
                          ),
                          TextSpan(
                            onEnter: (event) {},

                            text: 'Sign up',
                            style: AppTextStyles.workSansBold.copyWith(
                              color: AppColor.customPurple,
                              fontSize: 14.sp,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(
                                  Signup(),
                                  transition: Transition.rightToLeftWithFade,
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

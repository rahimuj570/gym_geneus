// exercise_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../res/assets/asset.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controllers/workoutcontroller.dart';
import '../model/workoutmodel.dart';
import 'package:kenzeno/app/modules/setting/controller/profilecontroller.dart';
import 'package:kenzeno/app/modules/home/controllers/homecontroller.dart';
import 'package:toastification/toastification.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final dynamic workutid;
  final int? challengeId;
  final int? exerciseIndex;
  final bool isChallenge;

  const ExerciseDetailsScreen({
    super.key,
    this.workutid,
    this.challengeId,
    this.exerciseIndex,
    this.isChallenge = false,
  });

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen>
    with TickerProviderStateMixin {
  final Rx<VideoPlayerController?> videoController = Rx<VideoPlayerController?>(
    null,
  );
  final RxBool isVideoLoading = false.obs;
  final RxBool isPlaying = false.obs;
  final RxInt remainingTime = 0.obs;
  final RxBool showCompleteButton = false.obs;
  final RxBool showInfoCard = false.obs;
  final RxBool hasTimerStarted = false.obs;

  late AnimationController slideController;
  late AnimationController playAnimController;

  late Animation<Offset> slideAnimation;
  late Animation<Offset> videoSlideUp;
  late Animation<Offset> statsSlideDown;
  late Animation<double> statsFadeIn;

  @override
  void initState() {
    super.initState();

    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    playAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));

    videoSlideUp = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: playAnimController, curve: Curves.easeOut),
        );

    statsSlideDown =
        Tween<Offset>(begin: const Offset(0, -0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: playAnimController,
            curve: Curves.easeOutBack,
          ),
        );

    statsFadeIn = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: playAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    slideController.dispose();
    playAnimController.dispose();
    videoController.value?.dispose();
    super.dispose();
  }

  void startTimer(int seconds) async {
    hasTimerStarted.value = true; // ← ADD THIS LINE!
    remainingTime.value = seconds;
    showCompleteButton.value = false;
    showInfoCard.value = true;
    slideController.forward();

    while (remainingTime.value > 0 && isPlaying.value) {
      await Future.delayed(const Duration(seconds: 1));
      if (isPlaying.value) remainingTime.value--;
    }

    if (remainingTime.value == 0) {
      showCompleteButton.value = true;
      isPlaying.value = false;
    }
  }

  void togglePlay(UserExercise exercise) async {
    final controller = videoController.value;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
      isPlaying.value = false;
      playAnimController.reverse();
    } else {
      controller.play();
      isPlaying.value = true;
      playAnimController.forward();
      if (remainingTime.value == 0) startTimer(exercise.durationSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserExercise exercise = Get.arguments ?? _getCurrentExercise();
    Get.find<VideoCleanupHelper>().registerController(videoController);

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        leading: const BackButtonBox(),
        centerTitle: true,
        title: Text(
          Get.find<WorkoutController>()
                  .selectedWorkoutDetail
                  .value
                  ?.difficulty ??
              'Exercise',
          style: AppTextStyles.poppinsBold.copyWith(
            color: AppColor.white,
            fontSize: 22.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Video / Thumbnail
                Obx(() {
                  final controller = videoController.value;
                  if (controller != null && controller.value.isInitialized) {
                    return SlideTransition(
                      position: videoSlideUp,
                      child: AnimatedScale(
                        scale: isPlaying.value ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        child: _buildVideoPlayer(controller),
                      ),
                    );
                  }
                  return SlideTransition(
                    position: videoSlideUp,
                    child: AnimatedScale(
                      scale: isPlaying.value ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: _buildThumbnailWithPlayButton(exercise),
                    ),
                  );
                }),

                SizedBox(height: 30.h),

                _buildExerciseInfo(exercise),

                Obx(() {
                  final bool shouldShowStats = hasTimerStarted.value
                      ? remainingTime.value > 0
                      : true;

                  return AnimatedOpacity(
                    opacity: shouldShowStats ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutQuart,
                    child: Offstage(
                      offstage: !shouldShowStats,
                      child: SlideTransition(
                        position: statsSlideDown,
                        child: FadeTransition(
                          opacity: statsFadeIn,
                          child: _buildColorfulStatItems(exercise),
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: 100.h),
              ],
            ),
          ),

          // Complete Exercise Button — fades in when done
          Obx(() {
            if (!showInfoCard.value) return const SizedBox();

            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: slideAnimation,
                child: Container(
                  margin: EdgeInsets.all(20.w),
                  padding: EdgeInsets.all(24.r),
                  child: AnimatedOpacity(
                    opacity: showCompleteButton.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    child: Visibility(
                      visible: showCompleteButton.value,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.isChallenge &&
                              widget.challengeId != null &&
                              widget.exerciseIndex != null) {
                            final homeCtrl = Get.find<HomeController>();
                            await homeCtrl.completeChallengeExercise(
                              challengeId: widget.challengeId!,
                              exerciseIndex: widget.exerciseIndex!,
                            );
                          } else {
                            // 1. Track progress (this shows the loading dialog)
                            await Get.find<WorkoutController>()
                                .trackWorkoutProgress(
                              userExerciseId: exercise.id,
                              userWorkoutId: widget.workutid,
                            );
                          }
                          // 2. Go back to Exercise list
                          Get.back(result: true);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.customPurple,
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 40.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          "Complete Exercise",
                          style: AppTextStyles.poppinsBold.copyWith(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController controller) {
    return Container(
      padding: EdgeInsets.all(12.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: Container(
          height: 300.h,
          width: double.infinity,
          color: Colors.black, // Background color to fill gaps
          child: FittedBox(
            fit: BoxFit.contain, // video will shrink to fit
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailWithPlayButton(UserExercise exercise) {
    final workout = Get.isRegistered<WorkoutController>()
        ? Get.find<WorkoutController>().selectedWorkoutDetail.value
        : null;

    final String imagePath = (workout?.image != null && workout!.image!.isNotEmpty)
        ? workout.image!
        : (Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>().activeCoachImagePath
            : ImageAssets.img_12);

    final Widget thumbnailImage = imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            width: double.infinity,
            height: 300.h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              final fallback = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>().activeCoachImagePath
                  : ImageAssets.img_12;
              return Image.asset(
                fallback,
                width: double.infinity,
                height: 300.h,
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            imagePath,
            width: double.infinity,
            height: 300.h,
            fit: BoxFit.cover,
          );

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: AppColor.customPurple),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            thumbnailImage,
            Container(
              width: double.infinity,
              height: 300.h,
              color: Colors.black.withOpacity(0.4),
            ),
            isVideoLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : GestureDetector(
                    onTap: () => _playVideo(exercise),
                    child: Container(
                      width: 84.w,
                      height: 84.w,
                      decoration: BoxDecoration(
                        color: AppColor.customPurple.withOpacity(0.95),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 50.sp,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInfo(UserExercise exercise) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 35.h),
    child: Center(
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: isPlaying.value
              ? Text(
                  "${remainingTime.value}s",
                  key: ValueKey('timer_${remainingTime.value}'),
                  style: AppTextStyles.poppinsBold.copyWith(
                    fontSize: 48.sp,
                    color: AppColor.customPurple,
                  ),
                  textAlign: TextAlign.center,
                )
              : Column(
                  key: const ValueKey('info'),
                  children: [
                    Text(
                      exercise.exerciseName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 22.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      exercise.exerciseDescription.isNotEmpty
                          ? exercise.exerciseDescription
                          : "No description available.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.sp,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );

  Widget _buildColorfulStatItems(UserExercise exercise) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF2A9DFF), Color(0xFF09C6F9)],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(ImageAssets.svg30, "${exercise.durationSeconds}s"),
          _statItem(ImageAssets.svg31, "${exercise.sets} × ${exercise.reps}"),
          _statItem(ImageAssets.svg32, "Rest ${exercise.restTime}s"),
        ],
      ),
    ),
  );

  Widget _statItem(String icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset(icon, height: 24.h, color: Colors.white),
      SizedBox(width: 6.w),
      Text(
        text,
        style: AppTextStyles.poppinsMedium.copyWith(
          fontSize: 13.sp,
          color: Colors.white,
        ),
      ),
    ],
  );

  UserExercise _getCurrentExercise() {
    return Get.find<WorkoutController>()
            .selectedWorkoutDetail
            .value
            ?.exercises
            ?.first ??
        UserExercise(
          id: 0,
          exerciseName: "Unknown",
          exerciseDescription: "",
          sets: 0,
          reps: 0,
          durationSeconds: 0,
          restTime: 0,
          order: 0,
          notes: "",
        );
  }

  Future<void> _playVideo(UserExercise exercise) async {
    if (isVideoLoading.value) return;

    if (exercise.videoUrl == null || exercise.videoUrl!.trim().isEmpty) {
      toastification.show(
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.orange,
        foregroundColor: Colors.white,
        title: Text(
          "Video Unavailable",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Video is not available for this exercise",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return;
    }

    isVideoLoading.value = true;

    try {
      await videoController.value?.dispose();
      videoController.value = null;

      final controller = exercise.videoUrl!.startsWith('http')
          ? VideoPlayerController.network(exercise.videoUrl!)
          : VideoPlayerController.asset(exercise.videoUrl!);

      videoController.value = controller;
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      isPlaying.value = true;

      playAnimController.forward();
      startTimer(exercise.durationSeconds);
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          "Error",
          style: AppTextStyles.poppinsBold.copyWith(color: Colors.white),
        ),
        description: Text(
          "Failed to play video",
          style: AppTextStyles.poppinsRegular.copyWith(color: Colors.white),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      videoController.value = null;
    } finally {
      isVideoLoading.value = false;
    }
  }
}

class VideoCleanupHelper extends GetxController {
  final List<Rx<VideoPlayerController?>> _controllers = [];

  void registerController(Rx<VideoPlayerController?> controllerRx) {
    _controllers.add(controllerRx);
  }

  @override
  void onClose() {
    for (var rx in _controllers) {
      rx.value?.dispose();
      rx.value = null;
    }
    super.onClose();
  }
}

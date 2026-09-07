import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../constants/appconstants.dart';
import '../../../res/assets/asset.dart';
import '../../../res/colors/colors.dart';
import '../../../res/fonts/textstyle.dart';
import '../../../widgets/backbutton_widget.dart';
import '../controllers/homecontroller.dart';
import '../models/workout_model.dart';

class WorkoutVideoPlayerScreen extends StatefulWidget {
  final WorkoutVideo video;

  const WorkoutVideoPlayerScreen({super.key, required this.video});

  @override
  State<WorkoutVideoPlayerScreen> createState() =>
      _WorkoutVideoPlayerScreenState();
}

class _WorkoutVideoPlayerScreenState extends State<WorkoutVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  bool _isYouTube = false;
  String _resolvedUrl = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  String _formatVideoUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('/')) {
      url = "${AppConstants.baseUrimage}$url";
    } else if (!url.startsWith('http://') &&
        !url.startsWith('https://') &&
        !url.startsWith('assets/')) {
      url = "${AppConstants.baseUrimage}/$url";
    }

    // Force https for the API server to avoid cleartext / redirect errors on Android ExoPlayer
    if (url.startsWith('http://api.gymgeniusai.co.uk')) {
      url = url.replaceFirst('http://', 'https://');
    }

    return url;
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isYouTube = false;
    });

    final rawUrl = widget.video.videoUrl;
    _resolvedUrl = _formatVideoUrl(rawUrl);

    print(
      "WorkoutVideoPlayer: Initializing with resolved URL: $_resolvedUrl (Raw: $rawUrl)",
    );

    if (_resolvedUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "Video URL is missing or empty";
      });
      return;
    }

    // Check if it's a YouTube link
    if (_resolvedUrl.contains('youtube.com') ||
        _resolvedUrl.contains('youtu.be')) {
      setState(() {
        _isLoading = false;
        _isYouTube = true;
      });
      return;
    }

    // Dispose old controller before creating a new one
    await _disposeController();

    // Strategy 1: Try without headers first (standard for S3 / public media files)
    bool success = await _tryInitializeController(withAuthHeader: false);

    // Strategy 2: If failed and it's on the api domain, try with Authorization header
    if (!success && _resolvedUrl.contains('gymgeniusai.co.uk')) {
      print("WorkoutVideoPlayer: Retrying with Auth Header...");
      success = await _tryInitializeController(withAuthHeader: true);
    }

    if (mounted) {
      if (success) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "Unable to stream this video file.";
        });
      }
    }
  }

  Future<bool> _tryInitializeController({required bool withAuthHeader}) async {
    try {
      await _disposeController();

      if (_resolvedUrl.startsWith('http://') ||
          _resolvedUrl.startsWith('https://')) {
        final uri = Uri.parse(_resolvedUrl);
        final token = GetStorage().read("loginToken");
        final headers = (withAuthHeader && token != null)
            ? <String, String>{'Authorization': 'Bearer $token'}
            : <String, String>{};

        _controller = VideoPlayerController.networkUrl(
          uri,
          httpHeaders: headers,
        );
      } else {
        _controller = VideoPlayerController.asset(_resolvedUrl);
      }

      await _controller!.initialize();
      _controller!.setLooping(true);
      await _controller!.play();

      _controller!.addListener(() {
        if (mounted) setState(() {});
      });

      return true;
    } catch (e) {
      print(
        "WorkoutVideoPlayer Init attempt error (withAuthHeader=$withAuthHeader): $e",
      );
      await _disposeController();
      return false;
    }
  }

  Future<void> _disposeController() async {
    if (_controller != null) {
      try {
        await _controller!.dispose();
      } catch (_) {}
      _controller = null;
    }
  }

  Future<void> _openInExternalBrowser() async {
    if (_resolvedUrl.isEmpty) return;
    try {
      final uri = Uri.parse(_resolvedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColor.black111214,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButtonBox(),
        title: Text(
          "Workout Video",
          style: AppTextStyles.poppinsBold.copyWith(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final currentVideo = homeController.workoutVideos.firstWhereOrNull(
              (v) => v.id == widget.video.id,
            );
            final isFav = currentVideo?.isFavorite ?? widget.video.isFavorite;

            return IconButton(
              icon: SvgPicture.asset(
                ImageAssets.svg33,
                height: 22.r,
                width: 22.r,
                colorFilter: ColorFilter.mode(
                  isFav ? AppColor.customPurple : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                homeController.toggleFavorite(
                  contentType: 'workoutvideo',
                  id: widget.video.id,
                );
              },
            );
          }),
          SizedBox(width: 10.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            // Video Player Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              height: 240.h,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColor.customPurple.withValues(alpha: 0.3),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColor.customPurple,
                      ),
                    )
                  else if (_isYouTube)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.redAccent,
                              size: 50.r,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "Watch on YouTube",
                              style: AppTextStyles.poppinsBold.copyWith(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton.icon(
                              onPressed: _openInExternalBrowser,
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Open Video",
                                style: AppTextStyles.poppinsMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.customPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_hasError)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_off_outlined,
                              color: Colors.redAccent,
                              size: 40.r,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : "Unable to stream video",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.poppinsMedium.copyWith(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _initPlayer,
                                  icon: Icon(
                                    Icons.refresh,
                                    size: 16.r,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Retry",
                                    style: AppTextStyles.poppinsMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.customPurple,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 6.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                                if (_resolvedUrl.isNotEmpty &&
                                    (_resolvedUrl.startsWith('http://') ||
                                        _resolvedUrl.startsWith(
                                          'https://',
                                        ))) ...[
                                  SizedBox(width: 8.w),
                                  OutlinedButton.icon(
                                    onPressed: _openInExternalBrowser,
                                    icon: Icon(
                                      Icons.open_in_browser,
                                      size: 16.r,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Browser",
                                      style: AppTextStyles.poppinsMedium
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_isInitialized && _controller != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showControls = !_showControls;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                          // Controls overlay
                          if (_showControls)
                            Container(
                              color: Colors.black38,
                              child: Center(
                                child: IconButton(
                                  iconSize: 54.r,
                                  icon: Icon(
                                    _controller!.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_controller!.value.isPlaying) {
                                        _controller!.pause();
                                      } else {
                                        _controller!.play();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          // Progress Bar & Duration at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87, Colors.transparent],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  VideoProgressIndicator(
                                    _controller!,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: AppColor.customPurple,
                                      bufferedColor: Colors.white24,
                                      backgroundColor: Colors.white10,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4.h,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(
                                          _controller!.value.position,
                                        ),
                                        style: AppTextStyles.poppinsRegular
                                            .copyWith(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                            ),
                                      ),
                                      Text(
                                        _formatDuration(
                                          _controller!.value.duration,
                                        ),
                                        style: AppTextStyles.poppinsRegular
                                            .copyWith(
                                              color: Colors.white70,
                                              fontSize: 11.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Video Information
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: AppTextStyles.poppinsBold.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.customPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColor.customPurple.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: AppColor.customPurple,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "${widget.video.durationMinutes} Minutes",
                                style: AppTextStyles.poppinsMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      "Description",
                      style: AppTextStyles.poppinsSemiBold.copyWith(
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.video.description.isNotEmpty
                          ? widget.video.description
                          : "No description provided for this workout video.",
                      style: AppTextStyles.poppinsRegular.copyWith(
                        color: AppColor.gray9CA3AF,
                        fontSize: 13.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/app/modules/setup/widgets/trainercard.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../subscription/views/subscription.dart';
import '../controllers/setup_controller.dart';
import '../service/service.dart';

class TrainerCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String subtitle;
  final SetupController controller = Get.find();

  TrainerCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.subtitle,
  }) : super(key: key);

  // This map matches your trainer names to backend IDs
  final Map<String, int> coachNameToId = {
    'John': 1,
    'Selma': 2,
    'Alex': 3,
    'Jara': 3,
    'Sophia': 4,
    'Chris': 4,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = controller.selectedTrainer.value == name;

      return GestureDetector(
        onTap: () async {
          controller.selectTrainer(name);
          final coachId = coachNameToId[name] ?? 1;
          controller.selectedCoachId.value = coachId;

          final setupService = Get.find<SetupService>();
          await setupService.updateCoach(coachId);
        },
        child: Container(
          width: 360.w,
          height: 400.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              width: 3.w,
            ),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h, left: 5.w, right: 5.w),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

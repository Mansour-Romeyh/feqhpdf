import 'package:feqh_book/core/const/approutes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  // Animation Controllers
  late AnimationController mainController;
  late AnimationController particleController;
  late AnimationController pulseController;
  late AnimationController oneTimeRotationController; // تم تغيير الاسم
  late AnimationController floatingController;

  // Animations
  late Animation<double> iconScaleAnimation;
  late Animation<double> iconRotationAnimation;
  late Animation<Offset> iconSlideAnimation;
  late Animation<double> backgroundAnimation;
  late Animation<double> glowAnimation;
  late Animation<double> textFadeAnimation;
  late Animation<Offset> textSlideAnimation;
  late Animation<double> loadingFadeAnimation;
  late Animation<double> oneTimeRotationAnimation; // تم تغيير الاسم
  late Animation<double> floatingAnimation;

  // Observable variables
  RxBool isAnimationComplete = false.obs;
  RxDouble loadingProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeControllers();
    setupAnimations();
    startAnimations();
  }

  void initializeControllers() {
    mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // تحكم في الدوران مرة واحدة فقط بسرعة
    oneTimeRotationController = AnimationController(
      duration: const Duration(milliseconds: 800), // سرعة أعلى
      vsync: this,
    );

    // تحكم في الحركة العمودية
    floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Listen to main animation completion
    mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isAnimationComplete.value = true;
        navigateToNextScreen();
      }
    });
  }

  void setupAnimations() {
    // Icon Scale Animation - أبطأ وأكثر سلاسة
    iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Icon Rotation Animation - دوران أولي
    iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Icon Slide Animation
    iconSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );

    // Background Animation
    backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Glow Animation - نبض مستمر
    glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    // Text Fade Animation
    textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Text Slide Animation
    textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Loading Fade Animation
    loadingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    // One Time Rotation Animation - دوران مرة واحدة فقط
    oneTimeRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: oneTimeRotationController,
        curve: Curves.easeInOut,
      ),
    );

    // Floating Animation - حركة عمودية ناعمة
    floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: floatingController, curve: Curves.easeInOut),
    );
  }

  void startAnimations() {
    mainController.forward();
    particleController.repeat();
    pulseController.repeat(reverse: true);
    oneTimeRotationController.forward(); // دوران مرة واحدة فقط
    floatingController.repeat(reverse: true);

    // Simulate loading progress
    simulateLoading();
  }

  void simulateLoading() {
    // محاكاة عملية التحميل
    for (int i = 0; i <= 100; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (loadingProgress.value < 1.0) {
          loadingProgress.value = i / 100;
        }
      });
    }
  }

  void navigateToNextScreen() {
    // تأخير قبل الانتقال للشاشة التالية
    Future.delayed(const Duration(seconds: 5), () {
      Get.offNamed(Approutes.homeScreen);
    });
  }

  void restartAnimation() {
    mainController.reset();
    particleController.reset();
    pulseController.reset();
    oneTimeRotationController.reset();
    floatingController.reset();
    loadingProgress.value = 0.0;
    isAnimationComplete.value = false;
    startAnimations();
  }

  void pauseAnimations() {
    mainController.stop();
    particleController.stop();
    pulseController.stop();
    oneTimeRotationController.stop();
    floatingController.stop();
  }

  void resumeAnimations() {
    mainController.forward();
    particleController.repeat();
    pulseController.repeat(reverse: true);
    if (!oneTimeRotationController.isCompleted) {
      oneTimeRotationController.forward();
    }
    floatingController.repeat(reverse: true);
  }

  @override
  void onClose() {
    mainController.dispose();
    particleController.dispose();
    pulseController.dispose();
    oneTimeRotationController.dispose();
    floatingController.dispose();
    super.onClose();
  }

  // Getters for easy access
  double get particleAnimationValue => particleController.value;
  double get pulseAnimationValue => pulseController.value;
  double get oneTimeRotationAnimationValue => oneTimeRotationController.value;
  double get floatingAnimationValue => floatingController.value;
  bool get isMainAnimationRunning => mainController.isAnimating;
  AnimationStatus get mainAnimationStatus => mainController.status;
}

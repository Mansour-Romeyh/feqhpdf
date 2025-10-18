import 'package:feqh_book/controller/splahcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as Math;

import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController controller = Get.put(SplashController());

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          controller.mainController,
          controller.particleController,
          controller.pulseController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // خلفية متحركة متدرجة
              _buildAnimatedBackground(controller),

              // جزيئات متحركة في الخلفية
              _buildParticleLayer(controller),

              // المحتوى الرئيسي
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة الكتاب مع تأثيرات متقدمة
                    _buildAnimatedIcon(controller),

                    const SizedBox(height: 50),

                    // النص مع انيميشن محسن
                    _buildAnimatedText(context, controller),

                    const SizedBox(height: 80),

                    // مؤشر التحميل الحديث
                    _buildModernLoadingIndicator(controller),
                  ],
                ),
              ),

              // تأثير الضوء المتحرك
              _buildLightEffect(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground(SplashController controller) {
    return AnimatedBuilder(
      animation: controller.backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5 + (controller.backgroundAnimation.value * 0.5),
              colors: [
                Color.lerp(
                  const Color(0xFF1A237E),
                  const Color(0xFF3949AB),
                  controller.backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF283593),
                  const Color(0xFF5C6BC0),
                  controller.backgroundAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  controller.backgroundAnimation.value,
                )!,
                const Color(0xFF0F0F23),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleLayer(SplashController controller) {
    return AnimatedBuilder(
      animation: controller.particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(controller.particleAnimationValue),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedIcon(SplashController controller) {
    return SlideTransition(
      position: controller.iconSlideAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          controller.pulseController,
          controller.oneTimeRotationController,
          controller.floatingController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              Math.sin(controller.floatingAnimationValue * 2 * Math.pi) * 8,
            ),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.shade100.withOpacity(0.4),
                    Colors.amber.shade300.withOpacity(0.2),
                    Colors.orange.shade400.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
                boxShadow: [
                  // الظل الداخلي المتوهج
                  BoxShadow(
                    color: Colors.amber.shade200.withOpacity(
                      controller.glowAnimation.value * 0.8,
                    ),
                    blurRadius: 60 + (controller.glowAnimation.value * 40),
                    spreadRadius: 15,
                  ),
                  // ظل خارجي للعمق
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                  // توهج إضافي
                  BoxShadow(
                    color: Colors.orange.shade300.withOpacity(
                      controller.pulseAnimationValue * 0.6,
                    ),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: ScaleTransition(
                scale: controller.iconScaleAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // حلقات دوارة في الخلفية - دوران مرة واحدة فقط
                    ...List.generate(3, (index) {
                      return Transform.rotate(
                        angle:
                            controller.oneTimeRotationAnimationValue *
                            (2 * Math.pi),
                        child: Container(
                          width: 260 - (index * 30),
                          height: 260 - (index * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amber.shade300.withOpacity(
                                (0.2 - index * 0.05) * // سماكة أقل
                                    controller.glowAnimation.value,
                              ),
                              width: 1, // سماكة أقل للحلقات
                            ),
                          ),
                        ),
                      );
                    }),

                    // الأيقونة الرئيسية - حجم أكبر وإطار أقل سماكة
                    Transform.rotate(
                      angle:
                          controller.oneTimeRotationAnimationValue *
                          2 *
                          Math.pi,
                      child: Container(
                        width: 250, // حجم أكبر للحاوي
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.shade200,
                              Colors.amber.shade400,
                              Colors.amber.shade600,
                              Colors.orange.shade500,
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.amber.shade400.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(125),
                          child: Container(
                            padding: const EdgeInsets.all(
                              8,
                            ), // padding أقل لجعل الصورة أكبر
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(117),
                              child: Image.asset(
                                'assets/app_icon.png',
                                width: 234, // حجم أكبر للصورة
                                height: 234,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // نقاط ضوئية دوارة - دوران مرة واحدة فقط
                    ...List.generate(8, (index) {
                      final angle =
                          (index / 8) * 2 * Math.pi +
                          controller.oneTimeRotationAnimationValue *
                              2 *
                              Math.pi;
                      final radius = 120.0;
                      return Transform.translate(
                        offset: Offset(
                          radius * Math.cos(angle),
                          radius * Math.sin(angle),
                        ),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber.shade300.withOpacity(
                              0.5 +
                                  0.5 *
                                      Math.sin(
                                        controller.particleAnimationValue *
                                                2 *
                                                Math.pi +
                                            index,
                                      ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.shade200.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedText(BuildContext context, SplashController controller) {
    return FadeTransition(
      opacity: controller.textFadeAnimation,
      child: SlideTransition(
        position: controller.textSlideAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.6,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'كتاب الفقه الميسر\n مسائل متنوعة وأجوبتها\n\nللدكتور عدنان بن عوض الرشيدي\nعضو هيئة التدريس بكلية الشريعة\nجامعة الكويت',
                  speed: const Duration(milliseconds: 60),
                ),
              ],
              isRepeatingAnimation: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoadingIndicator(SplashController controller) {
    return FadeTransition(
      opacity: controller.loadingFadeAnimation,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // نقاط متحركة محسنة
          AnimatedBuilder(
            animation: controller.particleController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final delay = index * 0.2;
                  final animValue =
                      (controller.particleAnimationValue + delay) % 1.0;
                  final scale =
                      0.5 + (0.5 * Math.sin(animValue * 2 * Math.pi).abs());
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.shade300.withOpacity(
                        0.4 + (0.6 * scale),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.shade200.withOpacity(0.6 * scale),
                          blurRadius: 8 * scale,
                          spreadRadius: 2 * scale,
                        ),
                      ],
                    ),
                    transform: Matrix4.identity()..scale(scale),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLightEffect(SplashController controller) {
    return AnimatedBuilder(
      animation: controller.particleController,
      builder: (context, child) {
        return Stack(
          children: [
            // تأثير ضوئي متحرك 1
            Positioned(
              top: -150 + (controller.particleAnimationValue * 300),
              right: -150 + (controller.particleAnimationValue * 200),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.shade100.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // تأثير ضوئي متحرك 2
            Positioned(
              bottom:
                  -100 +
                  (Math.sin(controller.particleAnimationValue * 2 * Math.pi) *
                      100),
              left:
                  -100 +
                  (Math.cos(controller.particleAnimationValue * 2 * Math.pi) *
                      100),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.orange.shade200.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// رسام الجزيئات المتحركة المحسن
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // جزيئات أكبر وأكثر تفصيلاً
    for (int i = 0; i < 30; i++) {
      final x =
          (size.width * (i / 30)) +
          (80 * Math.sin(animationValue * 2 * Math.pi + i * 0.5));
      final y =
          (size.height * ((i * 0.6) % 1)) +
          (60 * Math.cos(animationValue * 2 * Math.pi + i * 0.3));

      final opacity =
          0.05 + (0.15 * Math.sin(animationValue * 2 * Math.pi + i).abs());
      final radius =
          1.5 + (4 * Math.sin(animationValue * 2 * Math.pi + i * 0.7).abs());

      paint.color = Colors.amber.shade200.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);

      // إضافة توهج للجزيئات
      paint.color = Colors.amber.shade100.withOpacity(opacity * 0.5);
      canvas.drawCircle(Offset(x, y), radius + 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

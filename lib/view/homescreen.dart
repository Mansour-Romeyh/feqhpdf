import 'dart:math' as Math;
import 'dart:ui';

import 'package:feqh_book/controller/homecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          controller.drawerController,
          controller.backgroundController,
          controller.booksController,
          controller.questionsController,
          controller.particleController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              _buildAnimatedBackground(controller),
              _buildParticleLayer(controller),
              _buildMainContent(context, controller),
              _buildAnimatedDrawer(context, controller),
              _buildLightEffect(controller),
              _buildBookTitleButton(controller),
            ],
          );
        },
      ),
    );
  }

  // ================== Background ==================
  Widget _buildAnimatedBackground(HomeController controller) {
    return AnimatedBuilder(
      animation: controller.backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2 + (controller.backgroundAnimation.value * 0.3),
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
              stops: const [0.0, 0.4, 0.8, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ================== Particles ==================
  Widget _buildParticleLayer(HomeController controller) {
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

  // ================== Main Content ==================
  Widget _buildMainContent(BuildContext context, HomeController controller) {
    return Obx(() {
      // عرض PDF بملء الشاشة بالكامل بدون safe area
      if (controller.selectedPdfPath.value.isNotEmpty) {
        return _buildFullScreenPDFViewer(context, controller);
      }

      // الصفحة الرئيسية العادية
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child:
                    controller.isDrawerOpen.value
                        ? _buildWelcomeMessage()
                        : _buildContentArea(controller),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 60, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            'أهلاً وسهلاً',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'اختر من القائمة الجانبية ما تريد تصفحه',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(HomeController controller) {
    return Obx(() {
      final selectedBook = controller.selectedBook;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedBook != null) ...[
              Icon(
                selectedBook['icon'],
                size: 50,
                color: selectedBook['color'],
              ),
              const SizedBox(height: 15),
              Text(
                controller.currentBookTitle,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'تم اختيار هذا القسم',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ] else
              Text(
                'المحتوى سيظهر هنا حسب اختيارك',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    });
  }

  // عرض PDF بملء الشاشة مع خلفية كريمية
  Widget _buildFullScreenPDFViewer(
    BuildContext context,
    HomeController controller,
  ) {
    // Use WillPopScope to intercept system back button
    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedPdfPath.value.isNotEmpty) {
          controller.closePDF();
          return false; // prevent default pop
        }
        return true;
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF5F5DC), // لون كريمي للخلفية
        child: Stack(
          children: [
            // PDF Viewer - Full Screen
            Positioned.fill(
              child: Obx(() {
                if (controller.isLoadingPDF.value) {
                  return Container(
                    color: const Color(0xFFF5F5DC),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1A237E),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'جاري تحميل الملف...',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: PDFView(
                    filePath: controller.selectedPdfPath.value,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: 0,
                    fitPolicy: FitPolicy.BOTH, // يملأ العرض ويكبر النص تلقائياً
                    backgroundColor: const Color(0xFFF5F5DC), // خلفية كريمية
                    fitEachPage: true,
                    preventLinkNavigation: false,
                    onRender: (pages) {
                      controller.totalPages.value = pages ?? 0;
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      controller.pdfController = pdfViewController;
                    },
                    onPageChanged: (int? page, int? total) {
                      controller.currentPage.value = (page ?? 0) + 1;
                    },
                    onError: (error) {
                      Get.snackbar(
                        'خطأ',
                        'حدث خطأ في تحميل الملف: $error',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    },
                  ),
                );
              }),
            ),

            // Top Toolbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(Get.context!).padding.top,
                  left: 8,
                  right: 15,
                  bottom: 15,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // small gap then the book/pdf icon
                    const SizedBox(width: 10),
                    Icon(
                      controller.selectedBook?['icon'] ?? Icons.picture_as_pdf,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.currentBookTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Print Button
                    GestureDetector(
                      onTap: () => controller.printPDF(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          //  color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.print,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'طباعة',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            // Page Counter at Bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(Get.context!).padding.bottom + 15,
                  left: 20,
                  right: 20,
                  top: 15,
                ),
                child: Center(
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'صفحة ${controller.currentPage.value} من ${controller.totalPages.value}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== Drawer ==================
  Widget _buildAnimatedDrawer(BuildContext context, HomeController controller) {
    return SlideTransition(
      position: controller.drawerSlideAnimation,
      child: FadeTransition(
        opacity: controller.drawerFadeAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
              ],
            ),
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildBooksSection(controller),
                    const SizedBox(height: 20),
                    _buildQuestionsSection(controller),
                    const SizedBox(height: 20),
                    _buildContactButton(controller),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBooksSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'الكتب',
          icon: Icons.library_books_rounded,
          isExpanded: controller.isBooksExpanded,
          onTap: controller.toggleBooksExpansion,
        ),
        AnimatedBuilder(
          animation: controller.booksExpandAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                heightFactor: controller.booksExpandAnimation.value,
                child: Column(
                  children:
                      controller.books.asMap().entries.map((entry) {
                        return _buildBookItem(
                          book: entry.value,
                          index: entry.key,
                          controller: controller,
                        );
                      }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestionsSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'مسائل متنوعة',
          icon: Icons.quiz_rounded,
          isExpanded: controller.isQuestionsExpanded,
          onTap: controller.toggleQuestionsExpansion,
        ),
        AnimatedBuilder(
          animation: controller.questionsExpandAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                heightFactor: controller.questionsExpandAnimation.value,
                child: Column(
                  children:
                      controller.books.asMap().entries.map((entry) {
                        return _buildQuestionItem(
                          book: entry.value,
                          index: entry.key,
                          controller: controller,
                        );
                      }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactButton(HomeController controller) {
    return GestureDetector(
      onTap: controller.contactDeveloper,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.3),
              Colors.green.withOpacity(0.1),
            ],
          ),
          border: Border.all(color: Colors.green.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.phone, color: Colors.green.shade300),
            const SizedBox(width: 10),
            Text(
              'تواصل مع الدكتور ',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required RxBool isExpanded,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.amber.shade300),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                isExpanded.value
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookItem({
    required Map<String, dynamic> book,
    required int index,
    required HomeController controller,
  }) {
    return GestureDetector(
      onTap: () => controller.selectBook(index),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              book['gradient'][0].withOpacity(0.2),
              book['gradient'][1].withOpacity(0.2),
            ],
          ),
          border: Border.all(color: book['color'].withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(book['icon'], color: book['color']),
            const SizedBox(width: 10),
            Text(
              book['title'],
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem({
    required Map<String, dynamic> book,
    required int index,
    required HomeController controller,
  }) {
    return GestureDetector(
      onTap: () => controller.selectQuestionCategory(index),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              book['gradient'][0].withOpacity(0.2),
              book['gradient'][1].withOpacity(0.2),
            ],
          ),
          border: Border.all(color: book['color'].withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: book['color']),
            const SizedBox(width: 10),
            Text(
              "مسائل ${book['title']}",
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightEffect(HomeController controller) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller.backgroundController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(
                      0.05 + (controller.backgroundController.value * 0.05),
                    ),
                    Colors.transparent,
                  ],
                  radius: 1.5,
                  center: Alignment(
                    Math.sin(
                          controller.backgroundController.value * 2 * Math.pi,
                        ) *
                        0.7,
                    Math.cos(
                          controller.backgroundController.value * 2 * Math.pi,
                        ) *
                        0.7,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookTitleButton(HomeController controller) {
    return Positioned(
      top: 20,
      left: 20,
      child: Obx(() {
        // إخفاء الزر عند فتح PDF
        if (controller.selectedPdfPath.value.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            if (controller.isDrawerOpen.value) {
              controller.closeDrawer();
            } else {
              controller.openDrawer();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              minWidth: 50,
              maxWidth: MediaQuery.of(Get.context!).size.width * 0.6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!controller.isDrawerOpen.value) ...[
                  if (controller.selectedBook != null)
                    Icon(
                      controller.selectedBook!['icon'],
                      color: Colors.white,
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    controller.isDrawerOpen.value
                        ? ''
                        : controller.currentBookTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (controller.isDrawerOpen.value)
                  const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ================== Particle Painter ==================
class ParticlePainter extends CustomPainter {
  final double progress;
  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    const particleCount = 50;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * Math.pi + progress * 2 * Math.pi;
      final radius = size.width * 0.4;
      final x =
          size.width / 2 + radius * Math.cos(angle) * (0.3 + (i % 3) * 0.2);
      final y =
          size.height / 2 + radius * Math.sin(angle) * (0.3 + (i % 3) * 0.2);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

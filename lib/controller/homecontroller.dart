import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // Animation Controllers
  late AnimationController drawerController;
  late AnimationController backgroundController;
  late AnimationController booksController;
  late AnimationController questionsController;
  late AnimationController buttonController;
  late AnimationController particleController;

  // Animations
  late Animation<Offset> drawerSlideAnimation;
  late Animation<double> drawerFadeAnimation;
  late Animation<double> backgroundAnimation;
  late Animation<double> booksExpandAnimation;
  late Animation<double> questionsExpandAnimation;
  late Animation<double> buttonScaleAnimation;
  late Animation<double> buttonRotationAnimation;

  // Observable variables
  RxBool isDrawerOpen = false.obs;
  RxBool isBooksExpanded = false.obs;
  RxBool isQuestionsExpanded = false.obs;
  RxString selectedSection = ''.obs;
  RxInt selectedBookIndex = (-1).obs;
  RxBool isQuestionMode = false.obs;

  // PDF Variables
  RxString selectedPdfPath = ''.obs;
  RxBool isLoadingPDF = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 0.obs;
  PDFViewController? pdfController;

  // Data Lists
  final List<Map<String, dynamic>> books = [
    {
      'title': 'كتاب الطهارة',
      'icon': Icons.water_drop_rounded,
      'color': Colors.blue,
      'gradient': [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
      'pdfAsset': 'assets/pdfs/tahara.pdf',
      'questionsPdf': 'assets/pdfs/questions_tahara.pdf',
    },
    {
      'title': 'كتاب الصلاة',
      'icon': Icons.mosque_rounded,
      'color': Colors.green,
      'gradient': [Color(0xFF66BB6A), Color(0xFF4CAF50)],
      'pdfAsset': 'assets/pdfs/salah.pdf',
      'questionsPdf': 'assets/pdfs/questions_salah.pdf',
    },
    {
      'title': 'كتاب الصيام',
      'icon': Icons.brightness_3_rounded,
      'color': Colors.purple,
      'gradient': [Color(0xFFBA68C8), Color(0xFF9C27B0)],
      'pdfAsset': 'assets/pdfs/siam.pdf',
      'questionsPdf': 'assets/pdfs/questions_siam.pdf',
    },
    {
      'title': 'كتاب الحج',
      'icon': Icons.location_on_rounded,
      'color': Colors.orange,
      'gradient': [Color(0xFFFFB74D), Color(0xFFFF9800)],
      'pdfAsset': 'assets/pdfs/hajj.pdf',
      'questionsPdf': 'assets/pdfs/questions_hajj.pdf',
    },
    {
      'title': 'كتاب الزكاة',
      'icon': Icons.volunteer_activism_rounded,
      'color': Colors.teal,
      'gradient': [Color(0xFF4DB6AC), Color(0xFF009688)],
      'pdfAsset': 'assets/pdfs/zakat.pdf',
      'questionsPdf': 'assets/pdfs/questions_zakat.pdf',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    initializeControllers();
    setupAnimations();

    // فتح الدراور تلقائياً عند بدء الشاشة
    Future.delayed(Duration(milliseconds: 500), () {
      openDrawer();
    });
  }

  void initializeControllers() {
    drawerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    booksController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    questionsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void setupAnimations() {
    // Drawer Animations
    drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: drawerController, curve: Curves.easeOutCubic),
    );

    drawerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: drawerController, curve: Curves.easeOut));

    // Background Animation
    backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: backgroundController, curve: Curves.easeInOut),
    );

    // Books Expansion Animation
    booksExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: booksController, curve: Curves.easeOutBack),
    );

    // Questions Expansion Animation
    questionsExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: questionsController, curve: Curves.easeOutBack),
    );

    // Button Animations
    buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: buttonController, curve: Curves.easeInOut),
    );

    buttonRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: booksController, curve: Curves.easeInOut),
    );

    // Start background animation
    backgroundController.repeat(reverse: true);
    particleController.repeat();
  }

  void openDrawer() {
    isDrawerOpen.value = true;
    drawerController.forward();
  }

  void closeDrawer() {
    isDrawerOpen.value = false;
    drawerController.reverse();

    // إغلاق جميع القوائم المفتوحة
    if (isBooksExpanded.value) {
      booksController.reverse();
      isBooksExpanded.value = false;
    }
    if (isQuestionsExpanded.value) {
      questionsController.reverse();
      isQuestionsExpanded.value = false;
    }
  }

  void toggleBooksExpansion() {
    if (isBooksExpanded.value) {
      booksController.reverse();
      isBooksExpanded.value = false;
      selectedSection.value = '';
    } else {
      // إغلاق قائمة المسائل فورًا
      if (isQuestionsExpanded.value) {
        questionsController.reset();
        isQuestionsExpanded.value = false;
      }

      booksController.forward();
      isBooksExpanded.value = true;
      selectedSection.value = 'books';
    }
  }

  void toggleQuestionsExpansion() {
    if (isQuestionsExpanded.value) {
      questionsController.reverse();
      isQuestionsExpanded.value = false;
      selectedSection.value = '';
    } else {
      // إغلاق قائمة الكتب فورًا
      if (isBooksExpanded.value) {
        booksController.reset();
        isBooksExpanded.value = false;
      }

      questionsController.forward();
      isQuestionsExpanded.value = true;
      selectedSection.value = 'questions';
    }
  }

  void selectBook(int index) {
    selectedBookIndex.value = index;
    isQuestionMode.value = false;

    // تأثير انيميشن للزر المضغوط
    buttonController.forward().then((_) {
      buttonController.reverse();
    });

    // تحميل PDF الكتاب
    loadPDF(books[index]['pdfAsset']);

    // إغلاق الدراور بعد الاختيار
    Future.delayed(Duration(milliseconds: 300), () {
      closeDrawer();
    });
  }

  void selectQuestionCategory(int index) {
    selectedBookIndex.value = index;
    isQuestionMode.value = true;

    buttonController.forward().then((_) {
      buttonController.reverse();
    });

    // تحميل PDF المسائل
    loadPDF(books[index]['questionsPdf']);

    Future.delayed(Duration(milliseconds: 300), () {
      closeDrawer();
    });
  }

  // تحميل PDF من الأصول
  Future<void> loadPDF(String assetPath) async {
    try {
      isLoadingPDF.value = true;

      // إنشاء مجلد مؤقت للملف
      final directory = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final filePath = '${directory.path}/$fileName';

      // نسخ الملف من الأصول
      final byteData = await rootBundle.load(assetPath);
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      selectedPdfPath.value = filePath;
      currentPage.value = 1;
      totalPages.value = 0;

      isLoadingPDF.value = false;

      Get.snackbar(
        'تم التحميل',
        'تم تحميل الملف بنجاح',
        backgroundColor: const Color.fromARGB(255, 20, 3, 82),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoadingPDF.value = false;
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل الملف: $e',
        backgroundColor: const Color.fromARGB(255, 80, 47, 44),
        colorText: Colors.white,
      );
    }
  }

  // إغلاق PDF - إصدار محدث
  void closePDF() {
    selectedPdfPath.value = '';
    currentPage.value = 1;
    totalPages.value = 0;
    selectedBookIndex.value = -1;
    isQuestionMode.value = false;
    pdfController = null;
    selectedSection.value = '';

    // إعادة تشغيل animations
    Future.delayed(const Duration(milliseconds: 100), () {
      openDrawer();
    });
  }

  // التنقل للصفحة التالية
  void nextPage() {
    if (pdfController != null && currentPage.value < totalPages.value) {
      pdfController!.setPage(currentPage.value);
    }
  }

  // التنقل للصفحة السابقة
  void previousPage() {
    if (pdfController != null && currentPage.value > 1) {
      pdfController!.setPage(currentPage.value - 2);
    }
  }

  // طباعة PDF
  Future<void> printPDF() async {
    try {
      if (selectedPdfPath.value.isEmpty) {
        Get.snackbar(
          'خطأ',
          'لا يوجد ملف محدد للطباعة',
          backgroundColor: const Color.fromARGB(255, 87, 49, 47),
          colorText: Colors.white,
        );
        return;
      }

      // قراءة الملف كـ bytes
      final file = File(selectedPdfPath.value);
      final bytes = await file.readAsBytes();

      // فتح نافذة الطباعة
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: currentBookTitle,
      );

      Get.snackbar(
        'طباعة',
        'تم غلق نافذة الطباعة',
        backgroundColor: const Color.fromARGB(255, 20, 3, 82),
        colorText: const Color.fromARGB(255, 255, 255, 255),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الطباعة: $e',
        backgroundColor: const Color.fromARGB(255, 79, 38, 36),
        colorText: Colors.white,
      );
    }
  }

  // حفظ PDF في التخزين الداخلي
  Future<void> savePDFToStorage() async {
    try {
      // طلب الإذن للكتابة في التخزين
      PermissionStatus status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          Get.snackbar(
            'خطأ',
            'يجب السماح بالوصول للتخزين لحفظ الملف',
            backgroundColor: const Color.fromARGB(255, 70, 32, 30),
            colorText: Colors.white,
          );
          return;
        }
      }

      if (selectedPdfPath.value.isEmpty) {
        Get.snackbar(
          'خطأ',
          'لا يوجد ملف محدد للحفظ',
          backgroundColor: const Color.fromARGB(255, 68, 29, 26),
          colorText: Colors.white,
        );
        return;
      }

      // الحصول على مجلد التحميلات
      Directory? downloadsDirectory;

      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory == null) {
        throw Exception('لا يمكن الوصول لمجلد التحميلات');
      }

      // إنشاء اسم الملف
      final String bookTitle = currentBookTitle
          .replaceAll(' ', '_')
          .replaceAll('/', '_');
      final String fileName =
          '${bookTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String savePath = '${downloadsDirectory.path}/$fileName';

      // نسخ الملف
      final File sourceFile = File(selectedPdfPath.value);
      await sourceFile.copy(savePath);

      Get.snackbar(
        'تم الحفظ',
        'تم حفظ الملف في: $savePath',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ في حفظ الملف: $e',
        backgroundColor: const Color.fromARGB(255, 86, 36, 32),
        colorText: Colors.white,
      );
    }
  }

  Future<void> contactDeveloper() async {
    const emailAddress = 'dradnan1401@gmail.com';
    const subject = 'استفسار بخصوص تطبيق كتاب الفقه الميسر';
    const emailBody = 'السلام عليكم،\n\nأود التواصل معكم بخصوص...';

    final emailUrl =
        'mailto:$emailAddress?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(emailBody)}';

    try {
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(
          Uri.parse(emailUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // إظهار رسالة خطأ للمستخدم إذا لم يتم العثور على تطبيق بريد
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على تطبيق بريد إلكتروني. يرجى تثبيت تطبيق مثل Gmail.',
          backgroundColor: const Color.fromARGB(255, 71, 39, 37),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ في فتح الرابط: $e',
        backgroundColor: const Color.fromARGB(255, 74, 37, 35),
        colorText: Colors.white,
      );
    }
  }

  void restartAnimations() {
    drawerController.reset();
    booksController.reset();
    questionsController.reset();
    selectedSection.value = '';
    selectedBookIndex.value = -1;
    isBooksExpanded.value = false;
    isQuestionsExpanded.value = false;
    isQuestionMode.value = false;
    closePDF();

    Future.delayed(const Duration(milliseconds: 500), () {
      openDrawer();
    });
  }

  @override
  void onClose() {
    drawerController.dispose();
    backgroundController.dispose();
    booksController.dispose();
    questionsController.dispose();
    buttonController.dispose();
    particleController.dispose();
    super.onClose();
  }

  // Getters for easy access
  double get particleAnimationValue => particleController.value;
  bool get isAnyExpanded => isBooksExpanded.value || isQuestionsExpanded.value;

  Map<String, dynamic>? get selectedBook =>
      selectedBookIndex.value >= 0 ? books[selectedBookIndex.value] : null;

  String get currentBookTitle {
    if (selectedBookIndex.value >= 0) {
      final book = books[selectedBookIndex.value];
      return isQuestionMode.value ? 'مسائل ${book['title']}' : book['title'];
    }
    return 'القائمة';
  }
}

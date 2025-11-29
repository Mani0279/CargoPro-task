import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  late final TextEditingController phoneController;
  late final TextEditingController otpController;

  final RxBool isLoading = false.obs;
  final RxString verificationId = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString countryCode = '+91'.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    otpController = TextEditingController();
  }

  @override
  void onClose() {
    // Check if controllers are already disposed before disposing
    if (phoneController.hasListeners) {
      phoneController.dispose();
    }
    if (otpController.hasListeners) {
      otpController.dispose();
    }
    super.onClose();
  }

  void sendOTP() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (phoneController.text.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Combine country code with phone number
    final fullPhoneNumber = '${countryCode.value}${phoneController.text}';
    phoneNumber.value = fullPhoneNumber;

    isLoading.value = true;

    await _authService.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      onCodeSent: (verificationId) {
        this.verificationId.value = verificationId;
        isLoading.value = false;
        Get.toNamed(Routes.OTP_VERIFICATION);
        Get.snackbar(
          'Success',
          'OTP sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  void verifyOTP() async {
    if (otpController.text.isEmpty || otpController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Please enter valid 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    bool success = await _authService.verifyOTP(
      verificationId: verificationId.value,
      otp: otpController.text,
    );

    isLoading.value = false;

    if (success) {
      // Clear text fields before navigation
      phoneController.clear();
      otpController.clear();

      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void logout() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
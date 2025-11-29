import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_object_model.dart';
import '../../../services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<ApiObject> objects = <ApiObject>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchObjects();
  }

  Future<void> fetchObjects() async {
    try {
      print('🔄 Starting to fetch objects...');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _apiService.getAllObjects();

      print('✅ Fetched ${result.length} objects');
      objects.value = result;
      isLoading.value = false;

      if (result.isEmpty) {
        Get.snackbar(
          'Info',
          'No objects found. Create your first one!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } on Exception catch (e) {
      print('❌ Exception in fetchObjects: $e');
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load objects. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Unexpected error in fetchObjects: $e');
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> deleteObject(String id) async {
    try {
      // Show confirmation dialog
      bool? confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this object?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Optimistic update
      final removedObject = objects.firstWhere((obj) => obj.id == id);
      objects.removeWhere((obj) => obj.id == id);

      // Delete from server
      bool success = await _apiService.deleteObject(id);

      // Close loading dialog
      Get.back();

      if (success) {
        Get.snackbar(
          'Success',
          'Object deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Revert if failed
        objects.add(removedObject);
        Get.snackbar(
          'Error',
          'Failed to delete object',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Revert on error
      await fetchObjects();

      Get.snackbar(
        'Error',
        'Failed to delete object: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void refreshObjects() {
    fetchObjects();
  }
}
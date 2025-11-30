import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_object_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = StorageService();

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

      // Fetch default objects (IDs 1-13)
      final defaultObjects = await _apiService.getAllDefaultObjects();

      // Fetch user-created objects
      final createdIds = _storageService.getCreatedObjectIds();
      print('📦 Found ${createdIds.length} user-created object IDs: $createdIds');

      List<ApiObject> userCreatedObjects = [];
      if (createdIds.isNotEmpty) {
        userCreatedObjects = await _apiService.getObjectsByIds(createdIds);
        print('✅ Fetched ${userCreatedObjects.length} user-created objects');
      }

      // Combine both lists (user-created first, then defaults)
      objects.value = [...userCreatedObjects, ...defaultObjects];

      print('✅ Total objects: ${objects.length}');
      isLoading.value = false;

      if (objects.isEmpty) {
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

  // Check if object is user-created
  bool isUserCreatedObject(String? id) {
    if (id == null) return false;
    final createdIds = _storageService.getCreatedObjectIds();
    return createdIds.contains(id);
  }

  // Check if object can be deleted
  bool canDeleteObject(String? id) {
    if (id == null) return false;
    return isUserCreatedObject(id);
  }

  Future<void> deleteObject(String id) async {
    try {
      // Check if object can be deleted
      if (!canDeleteObject(id)) {
        Get.snackbar(
          'Cannot Delete',
          'This is a default API object and cannot be deleted. Only objects you create can be deleted.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

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

      // Remove from storage
      _storageService.removeCreatedObjectId(id);

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
        'Failed to delete object.',
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
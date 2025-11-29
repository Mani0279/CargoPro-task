import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_object_model.dart';
import '../../../services/api_service.dart';

class KeyValuePair {
  final String id;
  final TextEditingController keyController;
  final TextEditingController valueController;

  KeyValuePair({
    required this.id,
    String? key,
    String? value,
  })  : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }

  Map<String, String> toMap() {
    return {keyController.text: valueController.text};
  }
}

class ObjectFormController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final nameController = TextEditingController();
  final dataController = TextEditingController(); // For JSON mode

  final RxBool isLoading = false.obs;
  final RxBool isEdit = false.obs;
  final RxBool isJsonMode = false.obs; // Toggle between UI and JSON mode
  final Rx<ApiObject?> existingObject = Rx<ApiObject?>(null);

  final RxList<KeyValuePair> keyValuePairs = <KeyValuePair>[].obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    existingObject.value = Get.arguments as ApiObject?;

    if (existingObject.value != null) {
      isEdit.value = true;
      nameController.text = existingObject.value!.name;

      if (existingObject.value!.data != null &&
          existingObject.value!.data!.isNotEmpty) {
        // Convert existing data to key-value pairs
        existingObject.value!.data!.forEach((key, value) {
          keyValuePairs.add(
            KeyValuePair(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              key: key,
              value: value.toString(),
            ),
          );
        });

        // Also set JSON mode data
        dataController.text =
            const JsonEncoder.withIndent('  ').convert(existingObject.value!.data);
      }
    }

    // Add one empty pair by default
    if (keyValuePairs.isEmpty) {
      addKeyValuePair();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dataController.dispose();
    for (var pair in keyValuePairs) {
      pair.dispose();
    }
    super.onClose();
  }

  void addKeyValuePair() {
    keyValuePairs.add(
      KeyValuePair(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );
  }

  void removeKeyValuePair(String id) {
    final pair = keyValuePairs.firstWhere((p) => p.id == id);
    pair.dispose();
    keyValuePairs.removeWhere((p) => p.id == id);

    // Keep at least one pair
    if (keyValuePairs.isEmpty) {
      addKeyValuePair();
    }
  }

  void toggleMode() {
    if (isJsonMode.value) {
      // Switching from JSON to UI mode
      try {
        if (dataController.text.isNotEmpty) {
          final json = jsonDecode(dataController.text) as Map<String, dynamic>;

          // Clear existing pairs
          for (var pair in keyValuePairs) {
            pair.dispose();
          }
          keyValuePairs.clear();

          // Create new pairs from JSON
          json.forEach((key, value) {
            keyValuePairs.add(
              KeyValuePair(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                key: key,
                value: value.toString(),
              ),
            );
          });
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Invalid JSON format. Cannot switch to UI mode.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      // Switching from UI to JSON mode
      final dataMap = <String, dynamic>{};
      for (var pair in keyValuePairs) {
        if (pair.keyController.text.isNotEmpty) {
          dataMap[pair.keyController.text] = pair.valueController.text;
        }
      }
      if (dataMap.isNotEmpty) {
        dataController.text = const JsonEncoder.withIndent('  ').convert(dataMap);
      }
    }
    isJsonMode.value = !isJsonMode.value;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateData(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Data is optional
    }

    try {
      json.decode(value);
      return null;
    } catch (e) {
      return 'Invalid JSON format';
    }
  }

  String? validateKey(String? value, int index) {
    if (value == null || value.isEmpty) {
      // Only validate if value is also provided
      final pair = keyValuePairs[index];
      if (pair.valueController.text.isNotEmpty) {
        return 'Key is required';
      }
    }
    return null;
  }

  Future<void> saveObject() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      Map<String, dynamic>? dataMap;

      if (isJsonMode.value) {
        // JSON mode
        if (dataController.text.isNotEmpty) {
          dataMap = json.decode(dataController.text) as Map<String, dynamic>;
        }
      } else {
        // UI mode - build from key-value pairs
        dataMap = <String, dynamic>{};
        for (var pair in keyValuePairs) {
          if (pair.keyController.text.isNotEmpty) {
            dataMap[pair.keyController.text] = pair.valueController.text;
          }
        }
        if (dataMap.isEmpty) {
          dataMap = null;
        }
      }

      final object = ApiObject(
        id: existingObject.value?.id,
        name: nameController.text,
        data: dataMap,
      );

      if (isEdit.value && existingObject.value?.id != null) {
        await _apiService.updateObject(existingObject.value!.id!, object);
        Get.snackbar(
          'Success',
          'Object updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await _apiService.createObject(object);
        Get.snackbar(
          'Success',
          'Object created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save object: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
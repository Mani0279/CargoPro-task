import 'package:cargoprotask/modules/home/controllers/home_controller.dart';
import 'package:cargoprotask/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get.dart';
import 'package:flutter_crud_app/modules/home/controllers/home_controller.dart';
import 'package:flutter_crud_app/services/api_service.dart';
import 'package:flutter_crud_app/data/models/api_object_model.dart';

@GenerateMocks([ApiService])
import 'home_controller_test.mocks.dart';

void main() {
  group('HomeController Tests', () {
    late HomeController controller;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      Get.put<ApiService>(mockApiService);
      controller = HomeController();
    });

    tearDown(() {
      Get.reset();
    });

    test('fetchObjects updates objects list on success', () async {
      final mockObjects = [
        ApiObject(id: '1', name: 'Test', data: {}),
      ];

      when(mockApiService.getAllObjects())
          .thenAnswer((_) async => mockObjects);

      await controller.fetchObjects();

      expect(controller.objects.length, 1);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('fetchObjects sets error on failure', () async {
      when(mockApiService.getAllObjects())
          .thenThrow(Exception('Network error'));

      await controller.fetchObjects();

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });
}
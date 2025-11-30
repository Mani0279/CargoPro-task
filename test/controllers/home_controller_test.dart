import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:cargoprotask/services/api_service.dart';
import 'package:cargoprotask/data/models/api_object_model.dart';
import 'dart:convert';

// This will generate mock classes
@GenerateMocks([http.Client])
void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('getAllDefaultObjects returns list on success', () async {
      // This is an integration test - it calls the real API
      final result = await apiService.getAllDefaultObjects();

      expect(result, isA<List<ApiObject>>());
      expect(result.isNotEmpty, true);
    });

    test('ApiObject can be serialized and deserialized', () {
      final json = {
        'id': '1',
        'name': 'Test Object',
        'data': {'color': 'red', 'price': 100}
      };

      final object = ApiObject.fromJson(json);
      expect(object.id, '1');
      expect(object.name, 'Test Object');
      expect(object.data?['color'], 'red');

      final backToJson = object.toJson();
      expect(backToJson['name'], 'Test Object');
    });
  });
}
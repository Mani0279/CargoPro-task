import 'package:cargoprotask/data/models/api_object_model.dart';
import 'package:cargoprotask/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_connect/http/src/http/mock/http_request_mock.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_crud_app/services/api_service.dart';
import 'package:flutter_crud_app/data/models/api_object_model.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService();
    });

    test('getAllObjects returns list of objects on success', () async {
      final mockResponse = [
        {'id': '1', 'name': 'Test Object', 'data': {'key': 'value'}}
      ];

      when(mockClient.get(Uri.parse('https://api.restful-api.dev/objects')))
          .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      final result = await apiService.getAllObjects();

      expect(result, isA<List<ApiObject>>());
      expect(result.length, 1);
      expect(result[0].name, 'Test Object');
    });

    test('createObject returns created object on success', () async {
      final newObject = ApiObject(name: 'New Object', data: {'key': 'value'});
      final mockResponse = {
        'id': '123',
        'name': 'New Object',
        'data': {'key': 'value'}
      };

      final result = await apiService.createObject(newObject);

      expect(result, isA<ApiObject>());
      expect(result.name, 'New Object');
    });
  });
}
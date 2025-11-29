import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/api_object_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.restful-api.dev/objects';

  // GET - Fetch all objects
  Future<List<ApiObject>> getAllObjects({int page = 1, int limit = 20}) async {
    try {
      print('📡 Fetching objects from API...');
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Please check your internet connection');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final objects = jsonList.map((json) => ApiObject.fromJson(json)).toList();
        print('✅ Successfully fetched ${objects.length} objects');
        return objects;
      } else {
        throw Exception('Failed to load objects. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching objects: $e');
      rethrow;
    }
  }

  // GET - Fetch single object by ID
  Future<ApiObject> getObjectById(String id) async {
    try {
      print('📡 Fetching object with ID: $id');
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final object = ApiObject.fromJson(json.decode(response.body));
        print('✅ Successfully fetched object: ${object.name}');
        return object;
      } else {
        throw Exception('Failed to load object. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching object: $e');
      rethrow;
    }
  }

  // POST - Create new object
  Future<ApiObject> createObject(ApiObject object) async {
    try {
      print('📡 Creating object: ${object.name}');
      print('📡 Data: ${json.encode(object.toJson())}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(object.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdObject = ApiObject.fromJson(json.decode(response.body));
        print('✅ Successfully created object with ID: ${createdObject.id}');
        return createdObject;
      } else {
        throw Exception('Failed to create object. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating object: $e');
      rethrow;
    }
  }

  // PUT - Update object
  Future<ApiObject> updateObject(String id, ApiObject object) async {
    try {
      print('📡 Updating object with ID: $id');
      print('📡 Data: ${json.encode(object.toJson())}');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(object.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedObject = ApiObject.fromJson(json.decode(response.body));
        print('✅ Successfully updated object');
        return updatedObject;
      } else {
        throw Exception('Failed to update object. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating object: $e');
      rethrow;
    }
  }

  // DELETE - Delete object
  Future<bool> deleteObject(String id) async {
    try {
      print('📡 Deleting object with ID: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Successfully deleted object');
        return true;
      } else {
        throw Exception('Failed to delete object. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting object: $e');
      rethrow;
    }
  }
}
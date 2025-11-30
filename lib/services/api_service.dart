import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/api_object_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.restful-api.dev/objects';

  // GET - Fetch all default objects
  Future<List<ApiObject>> getAllDefaultObjects() async {
    try {
      print('📡 Fetching default objects from API...');
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final objects = jsonList.map((json) => ApiObject.fromJson(json)).toList();
        print('✅ Successfully fetched ${objects.length} default objects');
        return objects;
      } else {
        throw Exception('Failed to load objects. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching default objects: $e');
      rethrow;
    }
  }

  // GET - Fetch objects by IDs (for user-created objects)
  Future<List<ApiObject>> getObjectsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      print('📡 Fetching ${ids.length} objects by IDs...');

      // Build query string: ?id=1&id=2&id=3
      final queryParams = ids.map((id) => 'id=$id').join('&');
      final url = '$baseUrl?$queryParams';

      print('📡 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);

        // Handle both single object and array responses
        List<dynamic> jsonList;
        if (responseBody is List) {
          jsonList = responseBody;
        } else if (responseBody is Map) {
          jsonList = [responseBody];
        } else {
          jsonList = [];
        }

        final objects = jsonList.map((json) => ApiObject.fromJson(json)).toList();
        print('✅ Successfully fetched ${objects.length} objects by IDs');
        return objects;
      } else {
        print('⚠️ Failed to fetch some objects. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching objects by IDs: $e');
      return [];
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
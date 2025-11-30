import 'package:get_storage/get_storage.dart';

class StorageService {
  final _storage = GetStorage();
  static const String _createdObjectsKey = 'created_objects';

  // Get list of created object IDs
  List<String> getCreatedObjectIds() {
    final ids = _storage.read<List>(_createdObjectsKey);
    return ids?.map((e) => e.toString()).toList() ?? [];
  }

  // Add a created object ID
  void addCreatedObjectId(String id) {
    final ids = getCreatedObjectIds();
    if (!ids.contains(id)) {
      ids.add(id);
      _storage.write(_createdObjectsKey, ids);
      print('💾 Saved object ID: $id');
    }
  }

  // Remove a deleted object ID
  void removeCreatedObjectId(String id) {
    final ids = getCreatedObjectIds();
    ids.remove(id);
    _storage.write(_createdObjectsKey, ids);
    print('🗑️ Removed object ID: $id');
  }

  // Clear all stored IDs
  void clearCreatedObjects() {
    _storage.remove(_createdObjectsKey);
  }
}
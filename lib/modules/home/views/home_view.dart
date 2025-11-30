import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshObjects,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().logout();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.objects.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value && controller.objects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to load objects'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchObjects,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.objects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No objects found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.CREATE),
                  child: const Text('Create First Object'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchObjects,
          child: ListView.builder(
            itemCount: controller.objects.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final object = controller.objects[index];
              final isUserCreated = controller.isUserCreatedObject(object.id);
              final canDelete = controller.canDeleteObject(object.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                elevation: isUserCreated ? 3 : 1,
                color: isUserCreated ? Colors.blue.shade50 : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isUserCreated ? Colors.blue : Colors.grey,
                    child: Text(
                      object.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          object.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isUserCreated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'YOURS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${object.id ?? "N/A"}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      if (object.data != null && object.data!.isNotEmpty)
                        Text(
                          'Data: ${object.data!.keys.join(", ")}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (!canDelete)
                        Text(
                          '🔒 Read-only (Default API object)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: canDelete
                      ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (object.id != null) {
                        controller.deleteObject(object.id!);
                      }
                    },
                  )
                      : Tooltip(
                    message: 'Cannot delete default objects',
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey[400],
                    ),
                  ),
                  onTap: () {
                    Get.toNamed(Routes.DETAIL, arguments: object);
                  },
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to create page and wait for result
          final result = await Get.toNamed(Routes.CREATE);

          // If creation was successful, refresh the list
          if (result == true) {
            controller.refreshObjects();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(object.name[0].toUpperCase()),
                  ),
                  title: Text(
                    object.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${object.id ?? "N/A"}'),
                      if (object.data != null && object.data!.isNotEmpty)
                        Text(
                          'Data: ${object.data!.keys.join(", ")}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (object.id != null) {
                        controller.deleteObject(object.id!);
                      }
                    },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed(Routes.CREATE);
          controller.refreshObjects();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../controllers/detail_controller.dart';
import '../../../app/routes/app_routes.dart';

class DetailView extends GetView<DetailController> {
  DetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Object Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Get.toNamed(Routes.EDIT, arguments: controller.object.value);
              },
            ),
          ],
        ),
        body: Obx(() {
          final obj = controller.object.value;
          if (obj == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Card(
              child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('ID', obj.id ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow('Name', obj.name),
                  if (obj.data != null && obj.data!.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        const JsonEncoder.withIndent('  ')
                            .convert(obj.data),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ],
              ),
              ),
              ),
                  ],
              ),
          );
        }),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
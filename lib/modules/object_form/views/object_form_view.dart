import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/object_form_controller.dart';

class ObjectFormView extends GetView<ObjectFormController> {
  final bool isEdit;

  const ObjectFormView({Key? key, required this.isEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Object' : 'Create Object'),
        actions: [
          Obx(() => TextButton.icon(
            onPressed: controller.toggleMode,
            icon: Icon(
              controller.isJsonMode.value ? Icons.view_list : Icons.code,
              color: Colors.white,
            ),
            label: Text(
              controller.isJsonMode.value ? 'Form Mode' : 'JSON Mode',
              style: const TextStyle(color: Colors.white),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field (Always Visible)
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter object name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: controller.validateName,
              ),
              const SizedBox(height: 24),

              // Mode Indicator
              Obx(() => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.isJsonMode.value
                      ? Colors.blue.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.isJsonMode.value
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.isJsonMode.value
                          ? Icons.code
                          : Icons.view_list,
                      color: controller.isJsonMode.value
                          ? Colors.blue
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.isJsonMode.value
                          ? 'JSON Mode - For Advanced Users'
                          : 'Form Mode - User Friendly',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.isJsonMode.value
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),

              // Content based on mode
              Obx(() => controller.isJsonMode.value
                  ? _buildJsonMode()
                  : _buildFormMode()),

              const SizedBox(height: 24),

              // Save Button
              Obx(() => ElevatedButton(
                onPressed:
                controller.isLoading.value ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEdit ? Icons.save : Icons.add),
                    const SizedBox(width: 8),
                    Text(
                      isEdit ? 'Update Object' : 'Create Object',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    print('💾 Save button pressed');
    controller.saveObject();
  }

  // JSON Mode UI
  Widget _buildJsonMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data (JSON Format)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.dataController,
          decoration: const InputDecoration(
            hintText: '{"color": "red", "price": 999}',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            helperText: 'Optional: Leave empty if not needed',
          ),
          maxLines: 10,
          validator: controller.validateData,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Enter valid JSON format. Example:\n{"color": "red", "capacity": "256GB", "price": 999}',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // Form Mode UI
  Widget _buildFormMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Object Properties (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: controller.addKeyValuePair,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Field'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.keyValuePairs.asMap().entries.map((entry) {
            final index = entry.key;
            final pair = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Property ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (controller.keyValuePairs.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () =>
                                  controller.removeKeyValuePair(pair.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: ValueKey('key_${pair.id}'),
                        controller: pair.keyController,
                        decoration: const InputDecoration(
                          labelText: 'Key',
                          hintText: 'e.g., color',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                          prefixIcon: Icon(Icons.key, size: 20),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: ValueKey('value_${pair.id}'),
                        controller: pair.valueController,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          hintText: 'e.g., red',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                          prefixIcon: Icon(Icons.text_fields, size: 20),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add properties for your object. You can leave fields empty if not needed.',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
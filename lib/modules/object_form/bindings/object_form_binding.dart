import 'package:get/get.dart';
import '../controllers/object_form_controller.dart';
import '../../../services/api_service.dart';

class ObjectFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<ObjectFormController>(() => ObjectFormController());
  }
}
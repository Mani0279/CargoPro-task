import 'package:get/get.dart';
import '../../../data/models/api_object_model.dart';

class DetailController extends GetxController {
  final Rx<ApiObject?> object = Rx<ApiObject?>(null);

  @override
  void onInit() {
    super.onInit();
    object.value = Get.arguments as ApiObject?;
  }
}
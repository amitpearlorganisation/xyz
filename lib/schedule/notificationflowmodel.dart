import 'package:dio/dio.dart';
import '../features/create_flow/data/model/flow_model.dart';
import '../utilities/constants.dart';
import '../utilities/shared_pref.dart';

class NotificationFlow {
  // Assuming necessary models are already defined

  Future<List<FlowModel>> getFlow({required String flowId}) async {
    try {
      // Use the provided URL
      String url = "https://backend.savant.app/web/flow/$flowId";
      final token = await SharedPref().getToken();
       print("print flow id ${flowId}");
      Options options = Options(
        headers: {"Authorization": 'Bearer $token'},
      );

      Response response = await Dio().get(url, options: options);

      print("flow response ${response.data}");

      if (response.statusCode == 400) {
        print("inside the 400");
        // Handle the error as per your requirement
        return [];
      } else {
        var item = response.data['data']['record']; // Assuming the structure directly gives the flow data

        if (item == null) {
          return [];
        }

        List<FlowModel> flowList = [];
        for (var record in item) {
          List<FlowDataModel> flowData = [];
          for (var flow in record['flow']) {
            var promptId = flow['promptId'] ?? {};
            var resourceId = promptId['resourceId'] ?? {};
            var side1 = promptId['side1'] ?? {};
            var side2 = promptId['side2'] ?? {};

            flowData.add(FlowDataModel(
              promptName: promptId['name'] ?? "",
              promptId: promptId['_id'] ?? "",
              resourceTitle: resourceId['title'] ?? '',
              resourceType: resourceId['type'] ?? '',
              resourceContent: resourceId['content'] ?? '',
              side1Title: side1['title'] ?? "",
              side1Type: side1['type'] ?? "",
              side1Content: side1['content'] ?? "",
              side2Title: side2['title'] ?? "",
              side2Type: side2['type'] ?? "",
              side2Content: side2['content'] ?? "",
            ));
          }

          flowList.add(FlowModel(
            title: record['title'],
            id: record['_id'],
            categoryId: record['categoryId'],
            flowList: flowData,
          ));
        }

        return flowList; // Return the list of flow models
      }
    } catch (e) {
      // Handle exceptions accordingly
      print('Error: $e');
      return [];
    }
  }
}

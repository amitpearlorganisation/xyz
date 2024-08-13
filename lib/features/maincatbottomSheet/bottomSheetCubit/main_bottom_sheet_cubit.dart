
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:self_learning_app/features/maincatbottomSheet/mainBottomSheetRepo/MainBottomSheetRepo.dart';

import '../../subcategory/model/sub_cate_model.dart';
import '../bottomSheetModels/bottomSheetModels.dart';

part 'main_bottom_sheet_state.dart';

class MainBottomSheetCubit extends Cubit<MainBottomSheetState> {
  MainBottomSheetCubit() : super(MainBottomSheetInitial());

  void onGetSubCategoryList({required String rootId})async {
    emit(MainBottomSheetLoading());
    var res = await MainBottomSheetRepo.getAllSubCategory( rootId: rootId);
    List<SubCategoryModel1> catlist=[];
     List<dynamic> dataRes = res!.data['data']['record'];
    print("chalo dekhte h${dataRes}");
    if(res.statusCode==200){
      print("code inside the status code 200");
      if(dataRes.isEmpty){
        emit(DataisEmpty());
        print("hello word 222");
      }
      for(var data in dataRes){
        catlist.add(SubCategoryModel1(sId: data['_id'], userId: data["userId"], name:data["name"], keywords: [], catlist: []));
      }

      for (int i = 0; i < catlist.length; i++) {
        print("---------i");
        var resforLoopResp = await fetchSub(subCatid: catlist[i].sId.toString());
        print("----------forloopResp$resforLoopResp");

        // Parse the response and add subcategories to catlist[i].catlist
        var subDataRes = resforLoopResp!.data['data'];
        if (resforLoopResp.statusCode == 200) {
          for (var subData in subDataRes['record']) {
            catlist[i].catlist.add(SubCategoryModel1(
              sId: subData['_id'],
              userId: subData["userId"],
              name: subData["name"],
              keywords: [],
              createdAt: subData['createdAt'],
              updatedAt: subData['updatedAt'],
              iV: subData['__v'],
              catlist: [],
            ));

            // Fetch subcategories for each subcategory in catlist[i].catlist
            var subSubResponse = await fetchSub(subCatid: catlist[i].catlist.last.sId.toString());
            var subSubDataRes = subSubResponse!.data['data'];
            if (subSubResponse.statusCode == 200) {
              for (var subSubData in subSubDataRes['record']) {
                catlist[i].catlist.last.catlist.add(SubCategoryModel1(
                  sId: subSubData['_id'],
                  userId: subSubData["userId"],
                  name: subSubData["name"],
                  keywords: [],
                  createdAt: subSubData['createdAt'],
                  updatedAt: subSubData['updatedAt'],
                  iV: subSubData['__v'],
                  catlist: [],
                ));
                // You can continue nesting more loops for additional levels if needed
              }
            }
          }
        }
      }

      emit(MainBottomSheetLoaded(cateList: catlist));

    }
  }
  Future<Response?> fetchSub({required String subCatid}) async{
    var res = await MainBottomSheetRepo.getAllSubCategory( rootId: subCatid);
    return res;

  }

}

import 'package:bloc/bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meta/meta.dart';

import '../data/repo/signup_repo.dart';

part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit() : super(RegistrationInitial());
  userRegistration({required String name , required String email, required String password}) async {
    EasyLoading.show(status: "Loading...");
    await SignUpRepo.loginUser(name: name,email: email,password: password).then((value) async {
      EasyLoading.dismiss();
      print("status-$value");
      if (value == 201)  {
        EasyLoading.dismiss();

        EasyLoading.showSuccess("Signup Sucessfully",duration: Duration(seconds: 1));
        await Future.delayed(Duration(seconds: 2));

        emit(RegestrationSuccessFull());
      } else if(value == 400) {
        EasyLoading.dismiss();

        emit(RegestrationEmailExist());
        EasyLoading.showError("Email already Exists");

      }
    }).onError((error, stackTrace) {
      EasyLoading.dismiss();
      EasyLoading.showError(error.toString());

    });
}
}





import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:formz/formz.dart';
import 'package:self_learning_app/features/registration/bloc/signup_event.dart';
import 'package:self_learning_app/features/registration/bloc/signup_state.dart';
import '../../login/data/model/email.dart';
import '../../login/data/model/password.dart';
import '../data/model/name.dart';
import '../data/repo/signup_repo.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpRepo singUpRepo;

  SignUpBloc({required this.singUpRepo}) : super(const SignUpState()) {
    on<SignUpNameChanged>(_onNameChanged);
    on<SignUpEmailChanged>(_onEmailChanged);
    on<SignUpPasswordChanged>(_onPasswordChanged);
    on<ConfrimPassObsecure>(_onConfirmPassObsecure);
    on<PassObsecure>(_onPassObsecure);
    on<SignUpFormSubmitted>(_onFormSubmitted);
  }


  void _onPassObsecure(PassObsecure event, Emitter<SignUpState> emit) {
    emit(state.copyWith(passwordObsecure: !event.passwordObsecure));
  }

  void _onConfirmPassObsecure(ConfrimPassObsecure event, Emitter<SignUpState> emit) {
    emit(state.copyWith(confrimpasswordObsecure: !event.confirmpassword));
  }

  void _onNameChanged(SignUpNameChanged event, Emitter<SignUpState> emit) {
    final name = Name.dirty(event.name);
    emit(
      state.copyWith(
        name: name.valid ? name : Name.pure(event.name),
        status: Formz.validate([name, state.password,state.email,]),
      ),
    );
  }
  

  void _onEmailChanged(SignUpEmailChanged event, Emitter<SignUpState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email.valid ? email : Email.pure(event.email),
        status: Formz.validate([email, state.password]),
      ),
    );
  }
  
  

  void _onPasswordChanged(SignUpPasswordChanged event, Emitter<SignUpState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password.valid ? password : Password.pure(event.password),
        status: Formz.validate([state.email, password]),
      ),
    );
  }


  // void _onConfrimPasswordChanged(Confrim event, Emitter<SignUpState> emit) {
  //   final password = Password.dirty(event.password);
  //   emit(
  //     state.copyWith(
  //       password: password.valid ? password : Password.pure(event.password),
  //       status: Formz.validate([state.email, password]),
  //     ),
  //   );
  // }


  Future<void> _onFormSubmitted(SignUpFormSubmitted event,
      Emitter<SignUpState> emit,) async {
    EasyLoading.show();
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        status: Formz.validate([email, password]),
      ),
    );
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));

      await SignUpRepo.loginUser(name: state.name.value,email: state.email.value,password: state.password.value).then((value) async {
        EasyLoading.dismiss();
        print("status-$value");
        if (value == 201)  {
            EasyLoading.showSuccess("Signup Sucessfully",duration: Duration(seconds: 1));
            await Future.delayed(Duration(seconds: 2));

          emit(state.copyWith(status: FormzStatus.submissionSuccess,));
        } else if(value == 400) {
          emit(state.copyWith(status: FormzStatus.submissionFailure,statusText: 'Email already Exists'));
          EasyLoading.showError("Email already Exists");

        }
      }).onError((error, stackTrace) {
        print(error);
        print('myerror');
        emit(state.copyWith(status: FormzStatus.submissionFailure,statusText: error.toString()));
        EasyLoading.showSuccess("Somethings went wrong");

      });

    }
  }
}


import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import '../data/model/email.dart';
import '../data/model/password.dart';
import '../data/repo/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';


class MyFormBloc extends Bloc<MyFormEvent, MyFormState> {
  final LoginRepo loginRepo;

  MyFormBloc({required this.loginRepo}) : super(MyFormState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<FormSubmitted>(_onFormSubmitted);
    on<ChangeObsecure>(_onChangeObsecure);
  }

  void _onEmailChanged(EmailChanged event, Emitter<MyFormState> emit) {

    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email.valid ? email : Email.pure(event.email),
        status: Formz.validate([email, state.password]),
      ),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<MyFormState> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password.valid ? password : Password.pure(event.password),
        status: Formz.validate([state.email, password]),
      ),
    );
  }

  void _onChangeObsecure(ChangeObsecure event, Emitter<MyFormState> emit) {
    emit(
      state.copyWith(isObsecure: !event.isObsecure,status: FormzStatus.pure,),);
  }


  Future<void> _onFormSubmitted(FormSubmitted event,
      Emitter<MyFormState> emit,) async {
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

        await LoginRepo.loginUser(email: state.email.value,password: state.password.value).then((value) {
          if (value == 201) {
            emit(state.copyWith(status: FormzStatus.submissionSuccess,));
          }
          else if(value == 400){
            emit(state.copyWith(status: FormzStatus.submissionFailure,statusText: 'Invalid Credentials'));

          }
          else {
            emit(state.copyWith(status: FormzStatus.submissionFailure,statusText: 'Server Error'));
          }
        }).onError((error, stackTrace) {
          print(error);
          print('myerror');
          emit(state.copyWith(status: FormzStatus.submissionFailure,statusText: error.toString()));
        });

      }
    }



  }


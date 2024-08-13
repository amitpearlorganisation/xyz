
import 'package:equatable/equatable.dart';

abstract class MyFormEvent  {
  const MyFormEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends MyFormEvent {
  const EmailChanged({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}


class PasswordChanged extends MyFormEvent {
  const PasswordChanged({required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

class FormSubmitted extends MyFormEvent {}

class ChangeObsecure extends MyFormEvent{
  final bool isObsecure ;

  ChangeObsecure({required this.isObsecure});


}

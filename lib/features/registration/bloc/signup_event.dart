import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpNameChanged extends SignUpEvent {
  const SignUpNameChanged({required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

class SignUpEmailChanged extends SignUpEvent {
  const SignUpEmailChanged({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class SignUpPasswordChanged extends SignUpEvent {
  const SignUpPasswordChanged({required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

class ConfrimPassChanged extends SignUpEvent {
  const ConfrimPassChanged({required this.confirmpassword});

  final String confirmpassword;

  @override
  List<Object> get props => [confirmpassword];
}


class PassObsecure extends SignUpEvent {
  const PassObsecure({required this.passwordObsecure});

  final bool passwordObsecure;

  @override
  List<Object> get props => [passwordObsecure];
}

class ConfrimPassObsecure extends SignUpEvent {
  const ConfrimPassObsecure({required this.confirmpassword});
  
  final bool confirmpassword;

  @override
  List<Object> get props => [confirmpassword];
}



class SignUpFormSubmitted extends SignUpEvent {}

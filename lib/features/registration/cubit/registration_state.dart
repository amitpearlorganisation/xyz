part of 'registration_cubit.dart';

@immutable
abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}
class RegestrationSuccessFull extends RegistrationState{}
class RegestrationEmailExist extends RegistrationState{}
class RegestrationError extends RegistrationState {}
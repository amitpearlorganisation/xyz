import 'package:formz/formz.dart';

enum ConfirmPassValidationError { invalid }

class ConfirmPassword extends FormzInput<String, ConfirmPassValidationError> {
  const ConfirmPassword.pure([super.value = '']) : super.pure();
  const ConfirmPassword.dirty([super.value = '']) : super.dirty();


  @override
  ConfirmPassValidationError? validator(String? value) {
    return value!.length>4
        ? null
        : ConfirmPassValidationError.invalid;
  }
}
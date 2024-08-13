import 'package:formz/formz.dart';

enum NameValidationError { invalid }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure([super.value = '']) : super.pure();
  const Name.dirty([super.value = '']) : super.dirty();

  // static final _passwordRegex =
  // RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  NameValidationError? validator(String? value) {
    return value!.length>4
        ? null
        : NameValidationError.invalid;
  }
}
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:formz/formz.dart';
import 'package:formz/formz.dart';
import 'package:formz/formz.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/login/login_screen.dart';
import 'package:self_learning_app/features/registration/bloc/signup_bloc.dart';
import 'package:self_learning_app/features/registration/bloc/signup_event.dart';
import 'package:self_learning_app/features/registration/bloc/signup_state.dart';
import 'package:self_learning_app/features/registration/registration_screen.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';

import '../login/bloc/login_event.dart';
import 'cubit/registration_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  String _passwordError = '';
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationCubit, RegistrationState>(
      listener: (context, state) async{
       if(state is RegestrationSuccessFull)  {
       await  Future.delayed(Duration(seconds: 1));
       Navigator.pop(context);
       }
      },
      child: Scaffold(
          body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [

                      SizedBox(height: 150,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            Text("Savant", style: TextStyle(fontSize: 20, color: Colors.redAccent, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("Sign Up", style: TextStyle(fontSize: 15, color: Colors.cyan, fontWeight: FontWeight.w500),)
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                        ),
                        validator: (value) {
                          if (value?.trim() == null || value!.trim().isEmpty) {
                            return 'Name is required';
                          } else if (value!.trim().length < 3) {
                            return 'Name must be at least 3 letters';
                          } else if (!RegExp(r'^[a-zA-Z]').hasMatch(value!.trim())) {
                            return 'Name must start with a letter';
                          } else if (RegExp(r'^[\.\s]').hasMatch(value!.trim())) {
                            return 'Name cannot start with a space or a dot';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 10.0),
                        ),
                        validator: (value) {
                          final trimmedValue = value?.trim() ?? '';
                          if (trimmedValue.isEmpty) {
                            return 'Email is required';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(trimmedValue)) {
                            return 'Enter a valid email';
                          } else {
                            final allowedDomains = ['gmail.com', 'yahoo.com', 'hotmail.com'];
                            final domain = trimmedValue.split('@').last;
                            if (!allowedDomains.contains(domain)) {
                              return 'Invalid email domain. Allowed domains are: gmail.com, yahoo.com, hotmail.com';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(

                        controller: _confirmPasswordController,
                        obscureText: _isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'Re-enter your password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ?Icons.visibility_off: Icons.visibility  ,
                            ),
                            onPressed: () {
                              setState(() {
                                print("--dd ${_isConfirmPasswordVisible}");
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 10.0),
                        ),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          } else if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      if (_passwordError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _passwordError,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (_passwordController.text !=
                                  _confirmPasswordController.text) {
                                setState(() {
                                  _passwordError = 'Passwords do not match';
                                });
                              } else {
                                setState(() {
                                  _passwordError = '';
                                });

                                // Submit the form
                                context.read<RegistrationCubit>()
                                  ..userRegistration(name: _name.text.trim(),
                                      email: _email.text,
                                      password: _passwordController.text);
                              }
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text("I have already an account"),
                      TextButton(onPressed: () {
                        Navigator.pop(context);
                      }, child: Text("Login Here"))
                    ],
                  ),
                ),
              ))),
    );
  }
}

// 008869

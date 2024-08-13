import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formz/formz.dart';
import 'package:self_learning_app/features/dashboard/dashboard_screen.dart';
import 'package:self_learning_app/features/registration/registration_screen.dart';
import 'package:self_learning_app/utilities/colors.dart';
import 'package:self_learning_app/utilities/extenstion.dart';
import 'package:self_learning_app/utilities/shared_pref.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
        //  appBar: AppBar(title: const Text('Login')),
        body: BlocListener<MyFormBloc, MyFormState>(
            listener: (context, state) {
              if (state.status.isSubmissionSuccess) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                     DashBoardScreen(msgstatus: false,)), (Route<dynamic> route) => false);
              }
              if (state.status.isSubmissionInProgress) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Loging you in...')),
                  );
              }
              if (state.status.isSubmissionFailure) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                showDialog<void>(
                  context: context,
                  builder: (_) => SuccessDialog(dailogText: state.statusText),
                );
              }
            },
            child: Container(
              height: double.infinity,


              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: context.screenHeight * 0.30,
                               child: Stack(
                                 children: [
                                 Positioned(
                                   top:50,
                                   child: SvgPicture.asset(
                                   'assets/icons/blob.svg',
                                   height: 150,
                                   width: 150,
                                   fit: BoxFit.cover,color: Colors.red,

                               ),
                                 ),

                                   Positioned(
                                     top: 110,
                                     left: 40,
                                     child: Text(
                                       'Login',
                                       style: TextStyle(fontSize: 16, color: Colors.white),
                                     ),
                                   ),
                                 ],
                               ),




                              ),
                            ),
                            Image.asset("assets/boy.png", height: 150, width: 150,)
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: BlurryContainer(
                            
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft:Radius.circular(0),
                            bottomRight: Radius.circular(0)
                            ),
                            elevation: 10,
                            blur: 0.2,
                            color: Colors.white70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: context.screenHeight * 0.06,
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    const EmailInput(),
                                    SizedBox(
                                      height: context.screenHeight * 0.025,
                                    ),
                                    const PasswordInput(),
                                    SizedBox(
                                      height: context.screenHeight * 0.05,
                                    ),
                                    const SubmitButton(),
                                    SizedBox(
                                      height: context.screenHeight * 0.03,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("Don't have an Account?",style: TextStyle(
                                            fontSize: 16
                                        ),),
                                        TextButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignUpScreen(),
                                                )),
                                            child: const Text('Sign up',style: TextStyle(
                                                fontSize: 16,fontWeight: FontWeight.bold
                                            ),)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                                ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.red, Colors.purpleAccent],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: SvgPicture.asset(
                                    'assets/icons/wave.svg',
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                        left: context.screenWidth / 2.75,
                        top: context.screenHeight * 0.24,
                        child: Container(
                            height: context.screenHeight * 0.14,
                            width: context.screenWidth / 3.5,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child:  Center(
                              child:Image.asset("assets/savant.png"),
                            ))),

                  ],
                ),
              ),
            )));
  }
}

class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    print(context.screenWidth);
    return BlocBuilder<MyFormBloc, MyFormState>(
      builder: (context, state) {
        print('email state');
        return Container(
            padding: const EdgeInsets.only(left: 10, right: 5),
            //height: context.screenHeight * 0.1,
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.5, color: Colors.grey.shade300)

            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
/*
                initialValue: state.email.value,
*/
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                  hintText: 'david@gmail.com',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.email,
                    size: context.screenWidth>1280?50:context.screenWidth * 0.06,
                  ),
                  errorText: state.email.invalid
                      ? 'Please ensure the email entered is valid'
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  context.read<MyFormBloc>().add(EmailChanged(email: value));
                },
                textInputAction: TextInputAction.next,
              ),
            ));
      },
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<MyFormBloc, MyFormState>(
      builder: (context, state) {

        return Container(
            padding: const EdgeInsets.only(left: 10, right: 5),
            //height: context.screenHeight * 0.1,
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.5, color: Colors.grey.shade300)

            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                obscureText: !state.isObsecure,
/*
                initialValue: state.password.value,
*/
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        context.read<MyFormBloc>().add(ChangeObsecure(isObsecure: state.isObsecure));
                      },
                      icon: state.isObsecure == false
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility)),
                  hintText: 'Password',
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.lock,
                    size:context.screenWidth>1280?50:context.screenWidth * 0.06,
                  ),
                  errorText: state.password.invalid
                      ? 'Please ensure the Phone Number is valid'
                      : null,
                ),
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  context
                      .read<MyFormBloc>()
                      .add(PasswordChanged(password: value));
                },
                textInputAction: TextInputAction.next,
              ),
            ));
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyFormBloc, MyFormState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return GestureDetector(
          onTap: (){
            if (state.password.invalid) {
              context
                  .showSnackBar(const SnackBar(content: Text('Invalid password')));
            } else if (state.email.invalid) {
              context.showSnackBar(const SnackBar(content: Text('Invalid Email')));
            }
            SharedPref().clear();
            context.read<MyFormBloc>().add(FormSubmitted());
          },
          child: Container(
            alignment: Alignment.center,
            height: context.screenHeight * 0.065,
            width: context.screenWidth,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(45)
            ),
            child: Text("Login")
          ),
        );
      },
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String dailogText;

  const SuccessDialog({super.key, required this.dailogText});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.info),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      dailogText,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// 008869

Color generateColor(int redPercent, int pinkPercent, int lightPinkPercent) {
  // Red color RGB values
  int redR = 255;
  int redG = 0;
  int redB = 0;

  // Pink color RGB values
  int pinkR = 255;
  int pinkG = 192;
  int pinkB = 203;

  // Calculate weighted averages
  int finalR = ((redPercent / 100) * redR + (pinkPercent / 100) * pinkR + (lightPinkPercent / 100) * pinkR).round();
  int finalG = ((redPercent / 100) * redG + (pinkPercent / 100) * pinkG + (lightPinkPercent / 100) * pinkG).round();
  int finalB = ((redPercent / 100) * redB + (pinkPercent / 100) * pinkB + (lightPinkPercent / 100) * pinkB).round();

  return Color.fromRGBO(finalR, finalG, finalB, 1);
}
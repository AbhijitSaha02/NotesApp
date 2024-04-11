import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'package:notes_app/utils/dialogs/error_dialog.dart';

import 'package:notes_app/utils/size_config.dart';
import 'package:notes_app/widgets/berzier_container.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.title});

  final String? title;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void sendVerificationMail() async {
    context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'A verification mail has been sent to your email! Please verify!'),
        duration: Durations.extralong1,
      ));
    }
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        context.read<AuthBloc>().add(const AuthEventLogOut());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            const Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController textController,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              controller: textController,
              obscureText: isPassword,
              autocorrect: false,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () async {
        final email = emailController.text;
        final password = passwordController.text;

        context.read<AuthBloc>().add(
              AuthEventSignUp(email.trim(), password.trim()),
            );

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Signed up!'),
          duration: Durations.medium1,
        ));

        Future.delayed(const Duration(seconds: 2));
        sendVerificationMail();
      },
      child: Container(
        width: SizeConfig.screenWidth,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: const Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        context.read<AuthBloc>().add(const AuthEventShouldLogIn());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'N',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.displayLarge,
            fontSize: 60,
            fontWeight: FontWeight.w700,
            color: const Color(0xffe46b10),
          ),
          children: const [
            TextSpan(
              text: 'OT',
              style: TextStyle(color: Colors.black, fontSize: 45),
            ),
            TextSpan(
              text: 'ES',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 45),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        // _entryField("Username"),
        _entryField("Email id", emailController),
        _entryField("Password", passwordController, isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateSigningUp) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak Password.');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'E-mail is already in use.');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid E-mail.');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register...');
          }
        }
      },
      child: Scaffold(
        body: SizedBox(
          height: SizeConfig.screenHeight,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: const BezierContainer(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: SizeConfig.screenHeight * 0.2),
                      _title(),
                      const SizedBox(
                        height: 50,
                      ),
                      _emailPasswordWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      _submitButton(),
                      SizedBox(height: SizeConfig.screenHeight * 0.14),
                      _loginAccountLabel(),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        ),
      ),
    );
  }
}

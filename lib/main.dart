import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helpers/loading/loading_screen.dart';
import 'dart:developer' as devtools;

import 'package:notes_app/pages/notes_page.dart';
import 'package:notes_app/pages/login_page.dart';
import 'package:notes_app/pages/create_update_note_page.dart';
import 'package:notes_app/pages/sign_up_page.dart';
import 'package:notes_app/pages/welcome_page.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/auth/bloc/auth_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_event.dart';
import 'package:notes_app/services/auth/bloc/auth_state.dart';
import 'package:notes_app/services/auth/firebase_auth_provider.dart';
import 'package:notes_app/utils/size_config.dart';
import 'package:notes_app/constants/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    SizeConfig().init(context);

    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            bodyLarge: GoogleFonts.montserrat(textStyle: textTheme.bodyLarge)),
      ),
      routes: {
        createUpdateNotePageRoute: (context) => const CreateUpdateNotePage(),
      },
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment...',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateUninitialized) {
          context.read<AuthBloc>().add(const AuthEventInitialize());
          return const WelcomePage();
        } else if (state is AuthStateLoggedIn) {
          return const NotesPage();
        } else if (state is AuthStateLoggedOut) {
          return const WelcomePage();
        } else if (state is AuthStateLoggingIn) {
          return const LoginPage();
        } else if (state is AuthStateNeedsVerification) {
          devtools.log(state.toString());
          context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
          return const Scaffold(
            body: Center(
              child: Text(
                'Email Verification Sent. Please verify E-mail.',
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        } else if (state is AuthStateSigningUp) {
          return const SignUpPage();
        } else {
          devtools.log(state.toString());
          return const Scaffold(
            body: Center(
              child: Text(
                'Error',
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        }
      },
    );
  }
}

import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventShouldLogIn extends AuthEvent {
  const AuthEventShouldLogIn();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSignUp extends AuthEvent {
  final String email;
  final String password;

  const AuthEventSignUp(this.email, this.password);
}

class AuthEventShouldSignUp extends AuthEvent {
  const AuthEventShouldSignUp();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

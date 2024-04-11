import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

import 'package:notes_app/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment!',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateSigningUp extends AuthState {
  final Exception? exception;
  const AuthStateSigningUp({required super.isLoading, required this.exception});
}

class AuthStateLoggingIn extends AuthState {
  const AuthStateLoggingIn({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required super.isLoading, required this.user});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    String? loadingText,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

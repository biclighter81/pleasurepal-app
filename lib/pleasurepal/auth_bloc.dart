import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

const issuerUrl = 'https://keycloak.rimraf.de/realms/pleasurepal';
const clientId = 'pleasurepal-app';

Future<Client> getClient() async {
  var issuer = await Issuer.discover(Uri.parse(issuerUrl));
  var client = Client(issuer, clientId);
  return client;
}

void urlLauncher(String url) async {
  var uri = Uri.parse(url);
  if (await canLaunchUrl(uri) || Platform.isAndroid) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Credential> login() async {
  var client = await getClient();
  var authenticator = Authenticator(client,
      scopes: [
        'openid',
        'profile',
        'email',
        'address',
        'phone',
        'offline_access',
      ],
      port: 4000,
      urlLancher: urlLauncher);
  var c = await authenticator.authorize();
  if (Platform.isAndroid || Platform.isIOS) {
    closeInAppWebView();
  }
  return c;
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Credential credential;
  AuthSuccess(this.credential);
}

class AuthError extends AuthState {}

class AuthEvent {}

class AuthEventLogout extends AuthEvent {}

class AuthEventLogin extends AuthEvent {}

class AuthEventRefresh extends AuthEvent {}

class AuthEventCheck extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthEventLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        var c = await login();
        emit(AuthSuccess(c));
      } catch (e) {
        print(e);
        emit(AuthError());
      }
    });
  }
}

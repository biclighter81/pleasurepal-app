import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rust_bridge_template/pleasurepal/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(AuthEventLogin());
    BlocProvider.of<AuthBloc>(context).stream.listen((event) {
      if (event is AuthSuccess) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //try again button
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(AuthEventLogin());
              },
              child: const Text('Try again'),
            )
          ],
        ),
      ),
    );
  }
}

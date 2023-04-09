//Login page
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: Text('Home'),
            ),
            ElevatedButton(
                onPressed: () async {
                  var issuer = await Issuer.discover(Uri.parse(
                      'https://keycloak.rimraf.de/realms/pleasurepal'));
                  var client = new Client(issuer, 'pleasurepal');
                  urlLauncher(String url) async {
                    var uri = Uri.parse(url);
                    if (await canLaunchUrl(uri) || Platform.isAndroid) {
                      await launchUrl(uri);
                    } else {
                      throw 'Could not launch $url';
                    }
                  }

                  var authenticator = Authenticator(client,
                      scopes: [
                        'openid',
                        'profile',
                        'email',
                        'address',
                        'phone',
                        'offline_access'
                      ],
                      port: 4000,
                      urlLancher: urlLauncher);
                  var c = await authenticator.authorize();
                  if (Platform.isAndroid || Platform.isIOS) {
                    closeInAppWebView();
                  }
                  print(c.toJson());
                },
                child: Text('Login'))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pleasurepal/device/device_manager_bloc.dart';
import 'package:pleasurepal/engine/desktop_engine_provider.dart';
import 'package:pleasurepal/engine/engine_control_bloc.dart';
import 'package:pleasurepal/engine/engine_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pleasurepal/login.dart';
import 'package:pleasurepal/pleasurepal/auth_bloc.dart';
import 'package:pleasurepal/pleasurepal/socket_bloc.dart';

void main() {
  runApp(const PleasurepalApp());
}

class PleasurepalApp extends StatelessWidget {
  const PleasurepalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: buildApp(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data as Widget;
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Future<Widget> buildApp() async {
    /*if (!isDesktop()) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (Platform.isAndroid && androidInfo.version.sdkInt <= 30) {
        await [
          Permission.bluetooth,
          Permission.location,
          Permission.locationWhenInUse,
          Permission.locationAlways,
        ].request();
      }
      await [
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
      ].request();
    }*/
    EngineRepository repo = EngineRepository(DesktopEngineProvider());
    if (kDebugMode) {
      print("Debug mode, stopping engine first.");
      // Make sure the engine is stopped, just in case we've reloaded.
      repo.stop();
    }
    var socketBloc = SocketBloc();
    var authBloc = AuthBloc();
    authBloc.stream.listen((state) {
      if (state is AuthSuccess) {
        socketBloc.add(SocketEventConnect(state.credential));
      }
    });
    var engineControlBloc = EngineControlBloc(repo);
    engineControlBloc.add(EngineControlEventStart());
    var deviceControlBloc =
        DeviceManagerBloc(engineControlBloc.stream, engineControlBloc.add);
    socketBloc.stream.listen((state) {
      if (state is SocketCommand) {
        deviceControlBloc.add(DeviceManagerCommandEvent(state));
      }
    });
    engineControlBloc.stream.forEach((state) {
      if (state is ServerLogMessageState) {
        print(state.message.message);
      }
      if (state is ProviderLogMessageState) {
        print(state.message.message);
      }
      if (state is EngineServerCreatedState) {
        deviceControlBloc.add(DeviceManagerEngineStartedEvent());
      }
      if (state is EngineStoppedState) {
        deviceControlBloc.add(DeviceManagerEngineStoppedEvent());
      }
    });
    return MultiBlocProvider(providers: [
      BlocProvider(create: (ctx) => engineControlBloc),
      BlocProvider(create: (ctx) => deviceControlBloc),
      BlocProvider(create: (ctx) => authBloc),
      BlocProvider(create: (ctx) => socketBloc),
    ], child: const PleasurepalView());
  }
}

class PleasurepalView extends StatelessWidget {
  const PleasurepalView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'pleasurepal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            useMaterial3: true),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.purple,
            useMaterial3: true),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/': (context) => const PleasurepalPage(),
        });
  }
}

class PleasurepalPage extends StatelessWidget {
  const PleasurepalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('pleasurepal'),
        ),
        body: Center(
            child: Column(
          children: [
            Column(
              children: [
                BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                  if (state is AuthSuccess) {
                    return Column(children: [
                      Text(
                          "Hello ${state.credential.idToken.claims.preferredUsername}"),
                    ]);
                  } else {
                    return const Text("Not logged in");
                  }
                }),
                BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
                  builder: (context, state) {
                    var deviceBloc =
                        BlocProvider.of<DeviceManagerBloc>(context);
                    return Column(
                      children: [
                        for (var device in deviceBloc.devices)
                          Row(
                            children: [
                              Text(device.device!.name),
                              Switch(
                                  value: device.active,
                                  onChanged: (value) {
                                    deviceBloc.add(
                                        DeviceManagerDeviceActiveEvent(device));
                                  }),
                            ],
                          )
                      ],
                    );
                  },
                ),
              ],
            ),
            // start scanning button
            BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
                builder: (context, state) {
              var deviceBloc = BlocProvider.of<DeviceManagerBloc>(context);
              return TextButton(
                  onPressed: () {
                    deviceBloc.add(DeviceManagerStartScanningEvent());
                  },
                  child: const Text("Start Scanning"));
            }),
          ],
        )));
  }
}

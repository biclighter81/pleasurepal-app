import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pleasurepal/debug.dart';
import 'package:pleasurepal/device/device_manager_bloc.dart';
import 'package:pleasurepal/engine/desktop_engine_provider.dart';
import 'package:pleasurepal/engine/engine_control_bloc.dart';
import 'package:pleasurepal/engine/engine_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pleasurepal/login.dart';
import 'package:pleasurepal/pleasurepal/auth_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
        deviceControlBloc.add(DeviceManagerCommandEvent(state.command));
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
            fontFamily: GoogleFonts.poppins().fontFamily,
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            toggleButtonsTheme: ToggleButtonsThemeData(
              hoverColor: Colors.white,
              fillColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE6AFF))),
            buttonTheme: ButtonThemeData(
                buttonColor: const Color(0xFFBE6AFF),
                textTheme: ButtonTextTheme.primary),
            colorScheme: const ColorScheme(
                background: Color(0xff41414B),
                brightness: Brightness.light,
                error: Color(0xffFF0000),
                onBackground: Color(0xffFFFFFF),
                onError: Color(0xffFFFFFF),
                onPrimary: Color(0xffFFFFFF),
                onSecondary: Color(0xffFFFFFF),
                primary: Color(0xFFBE6AFF),
                primaryContainer: Color(0XFFFFFFFF),
                secondary: Color(0xffFFFFFF),
                surface: Color(0xff1E1E1E),
                onSurface: Color(0xffFFFFFF)),
            //color scheme background
            useMaterial3: true),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/': (context) => const PleasurepalPage(),
          '/debug': (context) => const DebugPage()
        });
  }
}

class PleasurepalPage extends StatelessWidget {
  const PleasurepalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff20202B),
          title: Text('pleasurepal'.toUpperCase(),
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w900)
                      .fontFamily)),
        ),
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Stack(fit: StackFit.expand, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Connect your devices'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          GoogleFonts.poppins(fontWeight: FontWeight.bold)
                              .fontFamily,
                    ),
                  ),
                  Text(
                    'Connect devices to use in pleasurepal'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 25),
                  BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
                      builder: (context, state) {
                    var deviceBloc =
                        BlocProvider.of<DeviceManagerBloc>(context);
                    return ElevatedButton(
                        onPressed: () => {
                              if (deviceBloc.scanning)
                                deviceBloc.add(DeviceManagerStopScanningEvent())
                              else
                                {
                                  deviceBloc
                                      .add(DeviceManagerStartScanningEvent())
                                }
                            },
                        child: Text(
                            deviceBloc.scanning
                                ? 'Stop scanning'.toUpperCase()
                                : 'Start scanning'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            )));
                  }),

                  //full width container
                  BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
                    builder: (context, state) {
                      var deviceBloc =
                          BlocProvider.of<DeviceManagerBloc>(context);
                      return Column(
                        children: [
                          for (var device in deviceBloc.devices)
                            Container(
                                width: double.infinity,
                                child: Row(children: [
                                  Text(
                                    device.device!.name.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold)
                                            .fontFamily),
                                  ),
                                  Spacer(),
                                  Switch(
                                      value: device.active,
                                      onChanged: (value) {
                                        deviceBloc.add(
                                            DeviceManagerDeviceActiveEvent(
                                                device));
                                      }),
                                ]),
                                decoration: BoxDecoration(
                                  color: Color(0xff20202B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 20),
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10))
                        ],
                      );
                    },
                  ),
                ],
              ),
            ])));
  }
}

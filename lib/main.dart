import 'dart:convert';
import 'dart:io';

import 'package:buttplug/buttplug.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_rust_bridge_template/device/device_manager_bloc.dart';
import 'package:flutter_rust_bridge_template/engine/desktop_engine_provider.dart';
import 'package:flutter_rust_bridge_template/engine/engine_control_bloc.dart';
import 'package:flutter_rust_bridge_template/engine/engine_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rust_bridge_template/engine/foreground_engine_provider.dart';
import 'package:flutter_rust_bridge_template/login.dart';
import 'package:flutter_rust_bridge_template/util/util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ffi.dart';

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
    var engineControlBloc = EngineControlBloc(repo);
    engineControlBloc.add(EngineControlEventStart());
    var deviceControlBloc =
        DeviceManagerBloc(engineControlBloc.stream, engineControlBloc.add);
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
      BlocProvider(create: (ctx) => deviceControlBloc)
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
        initialRoute: '/',
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Login'),
                ),
                // device list
                BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
                    builder: (context, state) {
                  var deviceBloc = BlocProvider.of<DeviceManagerBloc>(context);
                  return Column(
                    children: [
                      for (var device in deviceBloc.devices)
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  var cmd = ButtplugDeviceCommand.setVec(
                                      [VibrateComponent(2)]);
                                  device.device!.vibrate(cmd);
                                },
                                child: Text(device.device!.name)),
                            TextButton(
                                onPressed: () {
                                  device.device!.vibrate(
                                      ButtplugDeviceCommand.setVec(
                                          [VibrateComponent(0)]));
                                },
                                child: const Text("Stop")),
                          ],
                        )
                    ],
                  );
                }),
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

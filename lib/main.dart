import 'dart:convert';
import 'dart:io';

import 'package:buttplug/buttplug.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge_template/device/device_manager_bloc.dart';
import 'package:flutter_rust_bridge_template/engine/desktop_engine_provider.dart';
import 'package:flutter_rust_bridge_template/engine/engine_control_bloc.dart';
import 'package:flutter_rust_bridge_template/engine/engine_repo.dart';
import 'ffi.dart';

void main() {
  runApp(const MyApp());
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
      print("Engine started, starting device manager");
      deviceControlBloc.add(DeviceManagerEngineStartedEvent());
    }
    if (state is EngineStoppedState) {
      deviceControlBloc.add(DeviceManagerEngineStoppedEvent());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // These futures belong to the state and are only initialized once,
  // in the initState method.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("You're running on"),
          ],
        ),
      ),
    );
  }
}

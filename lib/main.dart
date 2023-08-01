import 'dart:async';
import 'package:camera_demo/debug_camera.dart';
import 'package:camera_demo/error_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Text('Error Details:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(errorDetails.exceptionAsString()),
              SizedBox(height: 20.0),
              Text('Stack Trace:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(errorDetails.stack.toString()),
            ],
          ),
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    Zone.current.handleUncaughtError(details.exception, details.stack!);
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ErrorNotifier()),
      ],
      child: Consumer<ErrorNotifier>(
        builder: (context, notifier, child) {
          if (notifier.hasError) {
            Future.microtask(() => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('An error occurred'),
                  content: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      Text('Error Message:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${notifier.errorMessage}'),
                    ],
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text('OK'),
                      onPressed: () {
                        notifier.clear();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )));
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: DebugCameraView(),
          );
        },
      ),
    );
  }
}

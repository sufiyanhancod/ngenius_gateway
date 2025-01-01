import 'package:flutter/material.dart';
import 'package:ngenius/ngenius.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _ngeniusPlugin = Ngenius(
      apiKey:
          'ZmI3ODhlODQtYmVlYi00ZWFkLWIwZGYtOWYxNWM3YWM0MmI0OjhmNzhhNmQ2LTI2MGQtNDdjYy1hZTA5LTc2OTliZjgzNmY3Yg==',
      outletId: '320d54c8-cb64-4199-9e51-be9611094a10');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ngenius'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () async {
              await _ngeniusPlugin.createOrder(
                amount: 100,
                currencyCode: 'AED',
                action: 'AUTH',
              );
            },
            child: const Text('Create Order'),
          ),
        ),
      ),
    );
  }
}

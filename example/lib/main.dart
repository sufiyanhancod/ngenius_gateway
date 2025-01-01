import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
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
  String _paymentUrl = 'Not started';
  final _ngeniusPlugin = Ngenius(
    baseUrl: 'https://api-gateway.sandbox.ngenius-payments.com',
    apiKey:
        'ZmI3ODhlODQtYmVlYi00ZWFkLWIwZGYtOWYxNWM3YWM0MmI0OjhmNzhhNmQ2LTI2MGQtNDdjYy1hZTA5LTc2OTliZjgzNmY3Yg==', // Replace with your actual API key
    outletId:
        '320d54c8-cb64-4199-9e51-be9611094a10', // Replace with your actual outlet ID
  );

  Future<void> createOrder() async {
    try {
      final paymentUrl = await _ngeniusPlugin.createOrder(
        amount: '100', // Amount in major units (e.g., dollars)
        currency: 'AED', // Currency code
      );

      setState(() {
        _paymentUrl = paymentUrl ?? 'Failed to get payment URL';
      });
    } on PlatformException catch (e) {
      setState(() {
        _paymentUrl = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ngenius Payment Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: createOrder,
                child: const Text('Create Order'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Payment URL: $_paymentUrl'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

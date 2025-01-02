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

  bool _isLoading = false;
  String _paymentStatus = '';

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
      _paymentStatus = 'Processing payment...';
    });

    try {
      final result = await _ngeniusPlugin.createOrder(
        amount: 100,
        currencyCode: 'AED',
        action: 'AUTH',
      );

      setState(() {
        if (result.success) {
          _paymentStatus = '✅ ${result.message}';
          if (result.data != null) {
            _paymentStatus += '\nStatus: ${result.data!['status']}';
          }
        } else {
          _paymentStatus = '❌ ${result.message}';
        }
      });
    } catch (e) {
      setState(() {
        _paymentStatus = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ngenius Payment Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _handlePayment,
                  child: const Text('Make Payment'),
                ),
              const SizedBox(height: 20),
              if (_paymentStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _paymentStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _paymentStatus.contains('✅')
                          ? Colors.green
                          : _paymentStatus.contains('❌')
                              ? Colors.red
                              : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ngenius/http/payment_service.dart';

import 'ngenius_platform_interface.dart';

class Ngenius {
  // Create a singleton for the plugin class and add mid and enckey to it.
  static final Ngenius _instance = Ngenius._internal();
  factory Ngenius({
    required String apiKey,
    required String outletId,
  }) {
    _instance.setApiKey(apiKey);
    _instance.setOutletId(outletId);

    return _instance;
  }
  Ngenius._internal();

  // Get the singleton.
  static Ngenius get instance => _instance;

  // Add mid and enckey to the singleton.
  late String _apiKey;
  late String _outletId;
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  void setOutletId(String outletId) {
    _outletId = outletId;
  }

  String get apiKey => _apiKey;
  String get outletId => _outletId;
  NgeniusPlatform get _ngeniusPlatform => NgeniusPlatform.instance;

  Future<void> createOrder({
    required double amount,
    String? email,
    String? description,
    required String currencyCode,
    required String action,
  }) async {
    final paymentService = NetworkPaymentService(
      apiKey: _apiKey,
      outletId: _outletId,
      isSandbox: true, // Use sandbox environment
    );

    try {
      final orderResponse = await paymentService.createOrder(
        amount: amount,
        currencyCode: currencyCode,
        action: action,
        email: email,
        description: description,
      );

      debugPrint('Order Response: $orderResponse');
      // The payment page URL can be found in the response
      final authUrl = orderResponse['_links']['payment-authorization']['href'];
      final paymentUrl = orderResponse['_links']['payment']['href'];

      debugPrint('Order created successfully!');
      debugPrint('Payment URL: $paymentUrl');
      debugPrint('Authorization URL: $authUrl');

      if (Platform.isAndroid) {
        await _ngeniusPlatform.createOrder(
          authUrl: authUrl,
          paymentUrl: paymentUrl,
        );
      } else if (Platform.isIOS) {
        final resp = await _ngeniusPlatform.showCardPaymentUI(
          response: jsonEncode(orderResponse),
        );
        debugPrint('Response: $resp');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}

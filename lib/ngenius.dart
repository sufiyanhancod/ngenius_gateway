// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ngenius_platform_interface.dart';

class NgeniusPaymentResult {
  final bool success;
  final String status;
  final String message;
  final Map<String, dynamic>? data;

  NgeniusPaymentResult({
    required this.success,
    required this.status,
    required this.message,
    this.data,
  });
}

class Ngenius {
  // Create a singleton for the plugin class and add mid and enckey to it.
  static final Ngenius _instance = Ngenius._internal();
  // factory Ngenius({

  // }) {

  //   return _instance;
  // }
  Ngenius._internal();

  // Get the singleton.
  static Ngenius get instance => _instance;

  // Add mid and enckey to the singleton.
  // Map<String, dynamic> orderResponse = {};

  // void setOrderResponse(Map<String, dynamic> orderResponse) {
  //   this.orderResponse = orderResponse;
  // }

  NgeniusPlatform get _ngeniusPlatform => NgeniusPlatform.instance;

  Future<NgeniusPaymentResult> createOrder({
    required Map<String, dynamic> orderPayload,
  }) async {
    try {
      debugPrint('Order Response: $orderPayload');
      if (Platform.isAndroid) {
        final authUrl = orderPayload['_links']['payment-authorization']['href'];
        final paymentUrl = orderPayload['_links']['payment']['href'];
        final result = await _ngeniusPlatform.createOrder(
          authUrl: authUrl,
          paymentUrl: paymentUrl,
        );
        log(result.toString());

        return _handlePaymentResult(result);
      } else if (Platform.isIOS) {
        final result = await _ngeniusPlatform.showCardPaymentUI(
          response: jsonEncode(orderPayload),
        );

        return _handlePaymentResult(result);
      }

      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'Current platform is not supported',
      );
    } catch (e) {
      if (e is PlatformException) {
        return NgeniusPaymentResult(
          success: false,
          status: e.code,
          message: e.message ?? 'Unknown error',
        );
      }
      return NgeniusPaymentResult(
        success: false,
        status: 'ERROR',
        message: e.toString(),
      );
    }
  }

  NgeniusPaymentResult _handlePaymentResult(dynamic result) {
    log(result.toString());
    if (result == 'AUTH_SUCCESS') {
      return NgeniusPaymentResult(
        success: true,
        status: 'AUTH_SUCCESS',
        message: 'Payment completed successfully',
      );
    }
    if (result == 'CAPTURE_SUCCESS') {
      return NgeniusPaymentResult(
        success: true,
        status: 'CAPTURE_SUCCESS',
        message: 'Payment completed successfully',
      );
    }
    if (result == 'PURCHASE_SUCCESS') {
      return NgeniusPaymentResult(
        success: true,
        status: 'PURCHASE_SUCCESS',
        message: 'Payment completed successfully',
      );
    }
    if (result == 'REVIEW_SUCCESS') {
      return NgeniusPaymentResult(
        success: true,
        status: 'REVIEW_SUCCESS',
        message: 'Payment completed successfully',
      );
    }

    // Handle specific error cases
    switch (result) {
      case 'PAYMENT_FAILED':
        return NgeniusPaymentResult(
          success: false,
          status: 'PAYMENT_FAILED',
          message: 'Payment was not successful',
        );
      case 'PAYMENT_CANCELLED':
        return NgeniusPaymentResult(
          success: false,
          status: 'PAYMENT_CANCELLED',
          message: 'Payment was cancelled by user',
        );
      case 'AUTH_FAILED':
        return NgeniusPaymentResult(
          success: false,
          status: 'AUTH_FAILED',
          message: 'Payment authorization failed',
        );
      case 'FAILED':
        return NgeniusPaymentResult(
          success: false,
          status: 'FAILED',
          message: 'Payment failed',
        );
      case 'ERROR':
        return NgeniusPaymentResult(
          success: false,
          status: 'ERROR',
          message: 'An unexpected error occurred',
        );
      case 'CANCELLED':
        return NgeniusPaymentResult(
          success: false,
          status: 'CANCELLED',
          message: 'Payment was cancelled by user',
        );
      default:
        return NgeniusPaymentResult(
          success: false,
          status: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred',
        );
    }
  }
}

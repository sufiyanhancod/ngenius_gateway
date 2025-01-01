import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'ngenius_platform_interface.dart';

class MethodChannelNgenius extends NgeniusPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('ngenius');

  @override
  Future<String?> createOrder({
    required String baseUrl,
    required String apiKey,
    required String outletId,
    required String amount,
    required String currency,
  }) async {
    try {
      // Step 1: Get access token
      final accessToken = await _fetchAccessToken(baseUrl, apiKey);
      if (accessToken == null) {
        throw PlatformException(
          code: 'ACCESS_TOKEN_ERROR',
          message: 'Failed to obtain access token',
        );
      }

      debugPrint('Access Token obtained: $accessToken');

      // Create order
      final paymentUrl = await _createPaymentOrder(
        baseUrl: baseUrl,
        token: accessToken,
        outletId: outletId,
        currency: currency,
        amount: amount,
      );

      if (paymentUrl == null) {
        throw PlatformException(
          code: 'CREATE_ORDER_ERROR',
          message: 'Failed to create payment order',
        );
      }

      debugPrint('Payment URL obtained: $paymentUrl');
      return paymentUrl;
    } catch (e) {
      debugPrint('Error in createOrder: $e');
      rethrow;
    }
  }

  Future<String?> _fetchAccessToken(String baseUrl, String apiKey) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.options.headers['Authorization'] =
          'Basic $apiKey'; // API key should be the full Basic auth header
      dio.options.headers['Content-Type'] =
          'application/vnd.ni-identity.v1+json';

      debugPrint('Fetching access token...');
      final response = await dio.post('/identity/auth/access-token');
      debugPrint('Access token response: ${response.data}');

      return response.data['access_token'] as String;
    } catch (e) {
      debugPrint('Error fetching access token: $e');
      return null;
    }
  }

  Future<String?> _createPaymentOrder({
    required String baseUrl,
    required String token,
    required String outletId,
    required String currency,
    required String amount,
  }) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] =
          'application/vnd.ni-payment.v2+json';
      dio.options.headers['Accept'] = 'application/vnd.ni-payment.v2+json';

      debugPrint('Creating payment order...');
      final response = await dio.post(
        '/transactions/outlets/$outletId/orders',
        data: {
          "action": "PURCHASE",
          "amount": {
            "currencyCode": currency,
            "value": int.parse(amount) * 100, // Convert to minor units
          }
        },
      );
      debugPrint('Payment order response: ${response.data}');

      return response.data["_embedded"]["payment"][0]["_links"]["payment:card"]
          ["href"] as String;
    } catch (e) {
      debugPrint('Error creating payment order: $e');
      return null;
    }
  }
}

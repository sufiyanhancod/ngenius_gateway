import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkPaymentService {
  final String apiKey;
  final String outletId;
  final bool isSandbox;

  NetworkPaymentService({
    required this.apiKey,
    required this.outletId,
    this.isSandbox = true,
  });

  String get _baseUrl => isSandbox
      ? 'api-gateway.sandbox.ngenius-payments.com'
      : 'api-gateway.ngenius-payments.com';

  /// Request access token from N-Genius Online identity service
  Future<String> _getAccessToken() async {
    final uri = Uri.https(_baseUrl, '/identity/auth/access-token');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/vnd.ni-identity.v1+json',
          'Authorization': 'Basic $apiKey',
        },
        body: jsonEncode({
          'realmName': 'ni',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        throw Exception('Failed to get access token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting access token: $e');
    }
  }

  /// Create an order using the access token
  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String currencyCode,
    String action = 'PURCHASE',
    String? email,
    String language = 'en',
    String? description,
  }) async {
    // First get the access token
    final accessToken = await _getAccessToken();

    // Create the order with the received token
    final uri = Uri.https(
      _baseUrl,
      '/transactions/outlets/$outletId/orders',
    );

    final Map<String, dynamic> orderPayload = {
      'action': action,
      'amount': {
        'currencyCode': currencyCode,
        'value': (amount * 100).toInt(), // Convert to minor units
      },
      'language': language,
    };

    // Add optional fields if provided
    if (email != null) orderPayload['emailAddress'] = email;
    if (description != null) orderPayload['description'] = description;

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/vnd.ni-payment.v2+json',
          'Accept': 'application/vnd.ni-payment.v2+json',
        },
        body: jsonEncode(orderPayload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderData = jsonDecode(response.body);
        return orderData;
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }
}

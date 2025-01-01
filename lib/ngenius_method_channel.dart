import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ngenius_platform_interface.dart';

/// An implementation of [NgeniusPlatform] that uses method channels.
class MethodChannelNgenius extends NgeniusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ngenius');

  @override
  Future<String?> createOrder({
    required String authUrl,
    required String paymentUrl,
  }) async {
    final version = await methodChannel.invokeMethod<String>('createOrder', {
      'authUrl': authUrl,
      'payPageUrl': paymentUrl,
    });
    return version;
  }
}

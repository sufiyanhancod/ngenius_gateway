import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ngenius/models/create_order_model.dart';

import 'ngenius_platform_interface.dart';

/// An implementation of [NgeniusPlatform] that uses method channels.
class MethodChannelNgenius extends NgeniusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ngenius');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> createOrder(CreateOrderModel orderDetails) async {
    try {
      final String? result = await methodChannel.invokeMethod(
          'createOrder', orderDetails.toJson());
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to create order: '${e.message}'.");
      return null;
    }
  }
}

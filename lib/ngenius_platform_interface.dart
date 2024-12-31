import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ngenius_method_channel.dart';

abstract class NgeniusPlatform extends PlatformInterface {
  /// Constructs a NgeniusPlatform.
  NgeniusPlatform() : super(token: _token);

  static final Object _token = Object();

  static NgeniusPlatform _instance = MethodChannelNgenius();

  /// The default instance of [NgeniusPlatform] to use.
  ///
  /// Defaults to [MethodChannelNgenius].
  static NgeniusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NgeniusPlatform] when
  /// they register themselves.
  static set instance(NgeniusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> createOrder({
    required String apiKey,
    required String outletId,
    required String amount,
    required String currency,
  });
}

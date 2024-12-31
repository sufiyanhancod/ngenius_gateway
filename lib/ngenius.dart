// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'ngenius_platform_interface.dart';

class Ngenius {
  // Create a singleton for the plugin class and add mid and enckey to it.
  static final Ngenius _instance = Ngenius._internal();
  factory Ngenius({required String apiKey, required String outletId}) {
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

  Future<String?> createOrder({
    required String amount,
    required String currency,
  }) {
    return _ngeniusPlatform.createOrder(
      apiKey: _apiKey,
      outletId: _outletId,
      amount: amount,
      currency: currency,
    );
  }
}

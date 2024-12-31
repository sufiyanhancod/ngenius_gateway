import 'package:flutter_test/flutter_test.dart';
import 'package:ngenius/ngenius.dart';
import 'package:ngenius/ngenius_platform_interface.dart';
import 'package:ngenius/ngenius_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNgeniusPlatform
    with MockPlatformInterfaceMixin
    implements NgeniusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NgeniusPlatform initialPlatform = NgeniusPlatform.instance;

  test('$MethodChannelNgenius is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNgenius>());
  });

  test('getPlatformVersion', () async {
    Ngenius ngeniusPlugin = Ngenius();
    MockNgeniusPlatform fakePlatform = MockNgeniusPlatform();
    NgeniusPlatform.instance = fakePlatform;

    expect(await ngeniusPlugin.getPlatformVersion(), '42');
  });
}

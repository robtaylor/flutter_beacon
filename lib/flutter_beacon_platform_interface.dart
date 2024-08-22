import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_beacon_method_channel.dart';

abstract class FlutterBeaconPlatform extends PlatformInterface {
  /// Constructs a FlutterBeaconPlatform.
  FlutterBeaconPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBeaconPlatform _instance = MethodChannelFlutterBeacon();

  /// The default instance of [FlutterBeaconPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBeacon].
  static FlutterBeaconPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBeaconPlatform] when
  /// they register themselves.
  static set instance(FlutterBeaconPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

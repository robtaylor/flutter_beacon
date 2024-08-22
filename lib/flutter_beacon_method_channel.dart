import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_beacon_platform_interface.dart';

/// An implementation of [FlutterBeaconPlatform] that uses method channels.
class MethodChannelFlutterBeacon extends FlutterBeaconPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_beacon');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

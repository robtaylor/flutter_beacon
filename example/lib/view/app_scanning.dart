import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_beacon_example/controller/requirement_state_controller.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';

class TabScanning extends StatefulWidget {
  const TabScanning({super.key});

  @override
  TabScanningState createState() => TabScanningState();
}

class TabScanningState extends State<TabScanning> {
  StreamSubscription<RangingResult>? _streamRanging;
  final log = Logger('TabScanningState');
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final controller = Get.find<RequirementStateController>();
  @override
  void initState() {
    super.initState();

    controller.startStream.listen((flag) {
      if (flag == true) {
        initScanBeacon();
      }
    });

    controller.pauseStream.listen((flag) {
      if (flag == true) {
        pauseScanBeacon();
      }
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    if (!controller.authorizationStatusOk ||
        !controller.locationServiceEnabled ||
        !controller.bluetoothEnabled) {
      log.info(
          'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
          'locationServiceEnabled=${controller.locationServiceEnabled}, '
          'bluetoothEnabled=${controller.bluetoothEnabled}');
      return;
    }
    final regions = <Region>[
      Region(
        identifier: 'Cubeacon',
        proximityUUID: 'CB10023F-A318-3394-4199-A8730C7C1AEC',
      ),
      Region(
        identifier: 'BeaconType2',
        proximityUUID: '6a84c716-0f2a-1ce9-f210-6a63bd873dd9',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      log.info(result);
      if (mounted) {
        setState(() {
          _regionBeacons[result.region] = result.beacons;
          _beacons.clear();
          for (var list in _regionBeacons.values) {
            _beacons.addAll(list);
          }
          _beacons.sort(_compareParameters);
        });
      }
    });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void dispose() {
    _streamRanging?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _beacons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: _beacons.map(
                  (beacon) {
                    return ListTile(
                      title: Text(
                        beacon.proximityUUID,
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text(
                              'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Text(
                              'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ).toList(),
            ),
    );
  }
}

// Copyright 2018 Duarte Silveira.All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'share.dart';

/// State<T extends StatefulWidget> extension class
/// to manage receiveShare stream subscription
abstract class ReceiveShareState<T extends StatefulWidget> extends State<T> {

  static const stream = const EventChannel('plugins.flutter.io/receiveshare');

  bool shareReceiveEnabled = false;
  StreamSubscription _shareReceiveSubscription = null;

  void enableShareReceiving() {
    if (_shareReceiveSubscription == null) {
      _shareReceiveSubscription =
          stream.receiveBroadcastStream().listen(_receiveShareInternal);
    }
    shareReceiveEnabled = true;
    debugPrint("enabled share receiving");
  }

  void disableShareReceiving() {
    if (_shareReceiveSubscription != null) {
      _shareReceiveSubscription.cancel();
      _shareReceiveSubscription = null;
    }
    shareReceiveEnabled = false;
    debugPrint("disabled share receiving");
  }

  void _receiveShareInternal(dynamic shared) {
    debugPrint("Share received - $shared");
    receiveShare(Share.fromReceived(shared));
  }

  void receiveShare(Share shared);

}

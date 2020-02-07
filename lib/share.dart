// Copyright 2018 Duarte Silveira
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

class ShareType {

  static const ShareType TYPE_PLAIN_TEXT = const ShareType._internal("text/plain");
  static const ShareType TYPE_IMAGE = const ShareType._internal("image/*");
  static const ShareType TYPE_FILE = const ShareType._internal("*/*");

  static List<ShareType> values() {
    List values = new List<ShareType>();
    values.add(TYPE_PLAIN_TEXT);
    values.add(TYPE_IMAGE);
    values.add(TYPE_FILE);
    return values;
  }

  final String _type;

  const ShareType._internal(this._type);

  static ShareType fromMimeType(String mimeType) {
    for(ShareType shareType in values()) {
      if (shareType.toString() == mimeType) {
        return shareType;
      }
    }
    return TYPE_FILE;
  }

  @override
  String toString() {
    return _type;
  }

}

/// Plugin for summoning a platform share sheet.
class Share {

  static const String TITLE = "title";
  static const String TEXT = "text";
  static const String PATH = "path";
  static const String TYPE = "type";
  static const String IS_MULTIPLE = "is_multiple";

  final ShareType mimeType;
  final String title;
  final String text;
  final String path;
  final List<Share> shares;

  Share.nullType() :
    this.mimeType = null,
    this.title = '',
    this.text = '',
    this.path = '',
    this.shares = const[]
  ;

  const Share.plainText({
    this.title,
    this.text
  }) : assert(text != null),
       this.mimeType = ShareType.TYPE_PLAIN_TEXT,
       this.path = '',
       this.shares = const[];

  const Share.file({
    this.mimeType = ShareType.TYPE_FILE,
    this.title,
    this.path,
    this.text = ''
  }) : assert(mimeType != null),
       assert(path != null),
       this.shares = const[];

  const Share.image({
    this.mimeType = ShareType.TYPE_IMAGE,
    this.title,
    this.path,
    this.text = ''
  }) : assert(mimeType != null),
       assert(path != null),
       this.shares = const[];

  const Share.multiple({
    this.mimeType = ShareType.TYPE_FILE,
    this.title,
    this.shares
  }) : assert(mimeType != null),
       assert(shares != null),
       this.text = '',
       this.path = '';


  static Share fromReceived(Map received) {
    assert(received.containsKey(TYPE));
    ShareType type = ShareType.fromMimeType(received[TYPE]);
    if (received.containsKey(IS_MULTIPLE)) {
      List<Share> receivedShares = new List();
      for (var i = 0; i < received.length-2; i++) {
        receivedShares.add(Share.file(path: received["$i"]));
      }
      if (received.containsKey(TITLE)) {
        return Share.multiple(mimeType: type, title: received[TITLE], shares: receivedShares);
      } else {
        return Share.multiple(mimeType: type, shares: receivedShares);
      }
    } else {
      return _fromReceivedSingle(received, type);
    }

  }

  // ignore: missing_return
  static Share _fromReceivedSingle(Map received, ShareType type) {
    switch (type) {
      case ShareType.TYPE_PLAIN_TEXT:
        if (received.containsKey(TITLE)) {
          return Share.plainText(title: received[TITLE], text: received[TEXT]);
        } else {
          return Share.plainText(text: received[TEXT]);
        }
        break;

      case ShareType.TYPE_IMAGE:
        if (received.containsKey(TITLE)) {
          if (received.containsKey(TEXT)) {
            return Share.image(path: received[PATH],
                title: received[TITLE],
                text: received[TEXT]);
          } else {
            return Share.image(path: received[PATH], text: received[TITLE]);
          }
        } else {
          return Share.image(path: received[PATH]);
        }
        break;

      case ShareType.TYPE_FILE:
        if (received.containsKey(TITLE)) {
          if (received.containsKey(TEXT)) {
            return Share.file(path: received[PATH],
                title: received[TITLE],
                text: received[TEXT]);
          } else {
            return Share.file(path: received[PATH], text: received[TITLE]);
          }
        } else {
          return Share.file(path: received[PATH]);
        }
        break;
    }

  }

  /// [MethodChannel] used to communicate with the platform side.
  @visibleForTesting
  static const MethodChannel channel = const MethodChannel('plugins.flutter.io/share');

  bool get isNull => this.mimeType == null;

  bool get isMultiple => this.shares.length > 0;

  Future<void> share({Rect sharePositionOrigin}) {
    final Map<String, dynamic> params = <String, dynamic>{
      TYPE: mimeType.toString(),
      IS_MULTIPLE: isMultiple
    };
    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }
    if (title != null && title.isNotEmpty) {
      params[TITLE] = title;
    }

    switch (mimeType) {
      case ShareType.TYPE_PLAIN_TEXT:
        if (isMultiple) {
          for(var i = 0; i < shares.length; i++) {
            params["$i"] = shares[i].text;
          }
        } else {
          params[TEXT] = text;
        }
        break;

      case ShareType.TYPE_IMAGE:
      case ShareType.TYPE_FILE:
        if (isMultiple) {
          for (var i = 0; i < shares.length; i++) {
            params["$i"] = shares[i].path;
          }
        } else {
          params[PATH] = path;
          if (text != null && text.isNotEmpty) {
            params[TEXT] = text;
          }
        }
        break;

    }



    return channel.invokeMethod('share', params);
  }

  @override
  String toString() {
    return 'Share{' + (this.isNull ? 'null }' : 'mimeType: $mimeType, title: $title, text: $text, path: $path, shares: $shares}');
  }

}

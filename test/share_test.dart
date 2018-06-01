// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:mockito/mockito.dart';
import 'package:share/share.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

void main() {
  MockMethodChannel mockChannel;

  setUp(() {
    mockChannel = new MockMethodChannel();
    // Re-pipe to mockito for easier verifies.
    Share.channel.setMockMethodCallHandler((MethodCall call) {
      mockChannel.invokeMethod(call.method, call.arguments);
    });
  });

  test('sharing null fails', () {
    expect(
      () => Share.plainText(text:null).share(),
      throwsA(const isInstanceOf<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing empty fails', () {
    expect(
      () => Share.plainText(text:'').share(),
      throwsA(const isInstanceOf<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing origin sets the right params', () async {
    await Share.plainText(text:
      'some text to share').share(
      sharePositionOrigin: new Rect.fromLTWH(1.0, 2.0, 3.0, 4.0),
    );
    verify(mockChannel.invokeMethod('share', <String, dynamic>{
      'text': 'some text to share',
      'originX': 1.0,
      'originY': 2.0,
      'originWidth': 3.0,
      'originHeight': 4.0,
    }));
  });

  test('sharing image with empty mimeType', () {
    expect(
      () =>
          Share.image(path: "content://0@media/external/images/media/2129").share(),
      throwsA(const isInstanceOf<AssertionError>()),
    );
    verifyZeroInteractions(mockChannel);
  });

  test('sharing image', () async {
    await Share.image(path: "content://0@media/external/images/media/2129",
        mimeType: ShareType.TYPE_IMAGE).share(
      sharePositionOrigin: new Rect.fromLTWH(1.0, 2.0, 3.0, 4.0),
    );
    verify(mockChannel.invokeMethod('share', <String, dynamic>{
      'path': "content://0@media/external/images/media/2129",
      'mimeType': ShareType.TYPE_IMAGE.toString(),
      'originX': 1.0,
      'originY': 2.0,
      'originWidth': 3.0,
      'originHeight': 4.0,
    }));
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}

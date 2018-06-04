// Copyright 2018 Duarte Silveira
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:share/receive_share_state.dart';

void main() {
  runApp(new DemoApp());
}

class DemoApp extends StatefulWidget {
  @override
  DemoAppState createState() => new DemoAppState();
}

class DemoAppState extends ReceiveShareState<DemoApp> {
  String _text = '';
  String _shared = '';

  @override
  void receiveShare(Share shared) {
    debugPrint("Share received - $shared");
    setState(() {
      _shared = shared.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
	enableShareReceiving();
    return new MaterialApp(
      title: 'Share Plugin Demo',
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Share Plugin Demo'),
          ),
          body: new Padding(
            padding: const EdgeInsets.all(24.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new TextField(
                  decoration: const InputDecoration(
                    labelText: 'Share:',
                    hintText: 'Enter some text and/or link to share',
                  ),
                  maxLines: 2,
                  onChanged: (String value) => setState(() {
                        _text = value;
                      }),
                ),
                const Padding(padding: const EdgeInsets.only(top: 24.0)),
                new Builder(
                  builder: (BuildContext context) {
                    return new RaisedButton(
                      child: const Text('Share'),
                      onPressed: _text.isEmpty
                          ? null
                          : () {
                              // A builder is used to retrieve the context immediately
                              // surrounding the RaisedButton.
                              //
                              // The context's `findRenderObject` returns the first
                              // RenderObject in its descendent tree when it's not
                              // a RenderObjectWidget. The RaisedButton's RenderObject
                              // has its position and size after it's built.
                              final RenderBox box = context.findRenderObject();
                              Share.plainText(text: _text).share(
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
//                              Share.image(path: "content://0@media/external/images/media/2129", mimeType: ShareType.TYPE_IMAGE).share(
//                                  sharePositionOrigin:
//                                      box.localToGlobal(Offset.zero) &
//                                          box.size);
                            },
                    );
                  },
                ),
                const Padding(padding: const EdgeInsets.only(top: 24.0)),
                new RaisedButton(
                  child: const Text('Toggle share receiving'),
                  onPressed: () {
                          if (!shareReceiveEnabled) {
                            enableShareReceiving();
                          } else {
                            disableShareReceiving();
                          }
                        },
                ),
                const Padding(padding: const EdgeInsets.only(top: 24.0)),
                new Text(_shared),
              ],
            ),
          )),
    );
  }

}

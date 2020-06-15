# Share Anything plugin

A Flutter plugin to share content from your Flutter app via the platform's share dialog and receive shares from other apps on the platform (currently only on Android).  

Wraps the ACTION_SEND Intent, and ACTION_SEND + ACTION_SEND_MULTIPLE IntentReceiver on Android
 and UIActivityViewController on iOS.

# this fork fixes v2 embedding

## Usage

To use this plugin

1. add share
```
 share:
    git:
     url: https://github.com/MperorM/flutter-share.git
```
 as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

2. to send any kind of share, in your main.dart:
```
import 'package:share/share.dart';
```
 then, just instantiate a Share with the corresponding named constructor, with the relevant named arguments:
```
Share.plainText(text: <String>, title: <String>);
Share.file(path: <String>, mimeType: ShareType, title: , text: );
Share.image(path: , mimeType: , title: , text: );
Share.multiple(shares: List<Share>, mimeType: , title: );
```
with only the first shown argument required,
and then call `.share(Rect sharePositionOrigin)`

3. to receive any kind of share, in your Android MainActivity replace `extends FlutterActivity` with `extends FlutterShareReceiverActivity` and in your main.dart:
```
import 'package:share/receive_share_state.dart';
```
 and then in your StatefulWidget replace your `extends State<T>` with `extends ReceiveShareState<T>` and implement your mandatory `@override void receiveShare(Share) { }` where you'll receive your shares.
 
 finally call ``enableShareReceiving();`` in your initState().

That's it!

## Example

Check out the example in the example project folder for a working example.

## Notes

Currently only the Android part is complete (IOS part does the same as google's original version), but be on the lookout for new versions, as the IOS part is being worked on and will soon do all the same bells and whistles.

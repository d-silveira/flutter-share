// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "SharePlugin.h"

static NSString *const PLATFORM_CHANNEL = @"plugins.flutter.io/share";

@implementation FLTSharePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *shareChannel =
      [FlutterMethodChannel methodChannelWithName:PLATFORM_CHANNEL
                                  binaryMessenger:registrar.messenger];

  [shareChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    if ([@"share" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];

        if ([arguments[@"text"] length] == 0 && arguments[@"is_multiple"] == false) {
        result(
            [FlutterError errorWithCode:@"error" message:@"Non-empty text expected" details:nil]);
        return;
      }

      NSNumber *originX = arguments[@"originX"];
      NSNumber *originY = arguments[@"originY"];
      NSNumber *originWidth = arguments[@"originWidth"];
      NSNumber *originHeight = arguments[@"originHeight"];

      CGRect originRect;
      if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
        originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                [originWidth doubleValue], [originHeight doubleValue]);
      }

      [self share:call.arguments
          withController:[UIApplication sharedApplication].keyWindow.rootViewController
                atSource:originRect];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
}

+ (void)share:(id)sharedItems
    withController:(UIViewController *)controller
          atSource:(CGRect)origin {
  NSString *share_type = sharedItems[@"type"];
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:sharedItems];
  //NSLog(share_type);
  UIActivityViewController *activityViewController = nil;
  if ([share_type isEqualToString:@"image/*"])
  {
      NSMutableArray *items = [[NSMutableArray alloc]init];
      //NSLog(path);
      NSNumber *multiple = sharedItems[@"is_multiple"];
      if ([multiple boolValue] == true){
          int i = 0;
          while ([[dict allKeys] containsObject:[@(i) stringValue]]) {
              UIImage *image = [UIImage imageWithContentsOfFile:[dict objectForKey:[@(i) stringValue]]];
              [items addObject:image];
              i++;
          }
      }else{
          NSString *path = sharedItems[@"path"];
          UIImage *image = [UIImage imageWithContentsOfFile:path];
          [items addObject:image];
      }
      activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:items
                                              applicationActivities:nil];
  } 
  else if ([share_type isEqualToString:@"*/*"])
  {
      NSMutableArray *items = [[NSMutableArray alloc]init];
      //NSLog(path);
      NSNumber *multiple = sharedItems[@"is_multiple"];
      if ([multiple boolValue] == true){
          int i = 0;
          while ([[dict allKeys] containsObject:[@(i) stringValue]]) {
              NSURL *url = [NSURL fileURLWithPath:[dict objectForKey:[@(i) stringValue]]];
              [items addObject:url];
              i++;
          }
      }else{
          NSString *path = sharedItems[@"path"];
          NSURL *url = [NSURL fileURLWithPath:path];
          [items addObject:url];
      }
      activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:items
                                              applicationActivities:nil];
  } 
  else if ([share_type isEqualToString:@"text/plain"])
  {
      NSMutableArray *items = [[NSMutableArray alloc]init];
      NSNumber *multiple = sharedItems[@"is_multiple"];
      if ([multiple boolValue] == true){
          int i = 0;
          while ([[dict allKeys] containsObject:[@(i) stringValue]]) {
              NSString *text = [dict objectForKey:[@(i) stringValue]];
              [items addObject:text];
              i++;
          }
      }else{
          NSString *text = sharedItems[@"text"];
          [items addObject:text];
      }
      activityViewController =
          [[UIActivityViewController alloc] initWithActivityItems:items
                                            applicationActivities:nil];
  } 
  else
  {
      NSLog(@"Unknown mimetype");
  }
    activityViewController.popoverPresentationController.sourceView = controller.view;
    if (!CGRectIsEmpty(origin)) {
        activityViewController.popoverPresentationController.sourceRect = origin;
    }
    [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end

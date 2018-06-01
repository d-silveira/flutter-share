// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.share;

import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import java.util.ArrayList;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Plugin method host for presenting a share sheet via Intent
 *
 * @author Duarte Silveira
 * @version 1
 * @since 25/05/18
 */
public class SharePlugin implements MethodChannel.MethodCallHandler {

	private static final String CHANNEL     = "plugins.flutter.io/share";
	public static final  String TITLE       = "title";
	public static final  String TEXT        = "text";
	public static final  String PATH        = "path";
	public static final  String TYPE        = "type";
	public static final  String IS_MULTIPLE = "is_multiple";

	public static enum ShareType{
		TYPE_PLAIN_TEXT("text/plain"),
		TYPE_IMAGE("image/*"),
		TYPE_FILE("*/*");

		String mimeType;

		ShareType(String mimeType) {
			this.mimeType = mimeType;
		}

		static ShareType fromMimeType(String mimeType) {
			for (ShareType shareType : values()) {
				if (shareType.mimeType.equals(mimeType)) {
					return shareType;
				}
			}
			return null;
		}

		@Override
		public String toString() {
			return mimeType;
		}
	}

	public static void registerWith(Registrar registrar) {
		MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
		SharePlugin instance = new SharePlugin(registrar);
		channel.setMethodCallHandler(instance);
	}

	private final Registrar mRegistrar;

	private SharePlugin(Registrar registrar) {
		this.mRegistrar = registrar;
	}

	@Override
	public void onMethodCall(MethodCall call, MethodChannel.Result result) {
		if (call.method.equals("share")) {
			if (!(call.arguments instanceof Map)) {
				throw new IllegalArgumentException("Map argument expected");
			}
			// Android does not support showing the share sheet at a particular point on screen.
			if (call.argument(IS_MULTIPLE)) {
				ArrayList<Uri> dataList = new ArrayList<>();
				for (int i = 0; call.hasArgument(Integer.toString(i)); i++) {
					dataList.add(Uri.parse((String)call.argument(Integer.toString(i))));
				}
				shareMultiple(dataList, (String) call.argument(TYPE), call.hasArgument(TITLE) ? (String) call.argument(TITLE) : "");
			} else {
				ShareType shareType = ShareType.fromMimeType((String) call.argument(TYPE));
				if (ShareType.TYPE_PLAIN_TEXT.equals(shareType)) {
					share((String) call.argument(TEXT), shareType, call.hasArgument(TITLE) ? (String) call.argument(TITLE) : "");
				} else {
					share((String) call.argument(PATH), (call.hasArgument(TEXT) ? (String) call.argument(TEXT) : ""), shareType, (call.hasArgument(TITLE) ? (String) call.argument(TITLE) : ""));
				}
			}
			result.success(null);
		} else {
			result.notImplemented();
		}
	}

	private void share (String text, ShareType shareType, String title) {
		share("", text, shareType, title);
	}

	private void share (String path, String text, ShareType shareType, String title) {
		if (!ShareType.TYPE_PLAIN_TEXT.equals(shareType) && (path == null || path.isEmpty())) {
			throw new IllegalArgumentException("Non-empty path expected");
		} else if (ShareType.TYPE_PLAIN_TEXT.equals(shareType) && (text == null || text.isEmpty())) {
			throw new IllegalArgumentException("Non-empty text expected");
		}
		if (shareType == null) {
			throw new IllegalArgumentException("Non-empty mimeType expected");
		}

		Intent shareIntent = new Intent();
		shareIntent.setAction(Intent.ACTION_SEND);
		if (!TextUtils.isEmpty(title)) {
			shareIntent.putExtra(Intent.EXTRA_SUBJECT, title);
		}
		if (!ShareType.TYPE_PLAIN_TEXT.equals(shareType)) {
			shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(path));
			if (!TextUtils.isEmpty(text)) {
				shareIntent.putExtra(Intent.EXTRA_TEXT, text);
			}
		} else {
			shareIntent.putExtra(Intent.EXTRA_TEXT, text);
		}
		shareIntent.setType(shareType.toString());
		Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);
		if (mRegistrar.activity() != null) {
			mRegistrar.activity().startActivity(chooserIntent);
		} else {
			chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			mRegistrar.context().startActivity(chooserIntent);
		}
	}

	private void shareMultiple(ArrayList<Uri> dataList, String mimeType, String title) {
		if (dataList == null || dataList.isEmpty()) {
			throw new IllegalArgumentException("Non-empty data expected");
		}
		if (mimeType == null || mimeType.isEmpty()) {
			throw new IllegalArgumentException("Non-empty mimeType expected");
		}

		Intent shareIntent = new Intent();
		shareIntent.setAction(Intent.ACTION_SEND_MULTIPLE);
		if (!TextUtils.isEmpty(title)) {
			shareIntent.putExtra(Intent.EXTRA_SUBJECT, title);
		}
		shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, dataList);
		shareIntent.setType(mimeType);
		Intent chooserIntent = Intent.createChooser(shareIntent, null /* dialog title optional */);
		if (mRegistrar.activity() != null) {
			mRegistrar.activity().startActivity(chooserIntent);
		} else {
			chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			mRegistrar.context().startActivity(chooserIntent);
		}
	}

}

package io.flutter.plugins.share;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

import static io.flutter.plugins.share.SharePlugin.IS_MULTIPLE;
import static io.flutter.plugins.share.SharePlugin.PATH;
import static io.flutter.plugins.share.SharePlugin.TEXT;
import static io.flutter.plugins.share.SharePlugin.TITLE;
import static io.flutter.plugins.share.SharePlugin.TYPE;

/**
 * main activity super, handles eventChannel sink creation
 * 					, share intent parsing and redirecting to eventChannel sink stream
 *
 * @author Duarte Silveira
 * @version 1
 * @since 25/05/18
 */
public class FlutterShareReceiverActivity extends FlutterActivity {

	public static final String STREAM = "plugins.flutter.io/receiveshare";

	private EventChannel.EventSink eventSink = null;
	private boolean inited = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		if (!inited) {
			init(getFlutterView(), this);
		}
	}

	public void init(BinaryMessenger flutterView, Context context) {
		Log.i(getClass().getSimpleName(), "initializing eventChannel");

		context.startActivity(new Intent(context, ShareReceiverActivityWorker.class));

		// Handle other intents, such as being started from the home screen
		new EventChannel(flutterView, STREAM).setStreamHandler(new EventChannel.StreamHandler() {
			@Override
			public void onListen(Object args, EventChannel.EventSink events) {
				Log.i(getClass().getSimpleName(), "adding listener");
				eventSink = events;
			}

			@Override
			public void onCancel(Object args) {
				Log.i(getClass().getSimpleName(), "cancelling listener");
				eventSink = null;
			}
		});

		inited = true;

	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		handleIntent(intent);
	}

	public void handleIntent(Intent intent) {
		// Get intent, action and MIME type
		String action = intent.getAction();
		String type = intent.getType();

		if (Intent.ACTION_SEND.equals(action) && type != null) {
			if ("text/plain".equals(type)) {
				String sharedTitle = intent.getStringExtra(Intent.EXTRA_SUBJECT);
				Log.i(getClass().getSimpleName(), "receiving shared title: " + sharedTitle);
				String sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
				Log.i(getClass().getSimpleName(), "receiving shared text: " + sharedText);
				if (eventSink != null) {
					Map<String, String> params = new HashMap<>();
					params.put(TYPE, type);
					params.put(TEXT, sharedText);
					if (!TextUtils.isEmpty(sharedTitle)) {
						params.put(TITLE, sharedTitle);
					}
					eventSink.success(params);
				}
			} else {
				String sharedTitle = intent.getStringExtra(Intent.EXTRA_SUBJECT);
				Log.i(getClass().getSimpleName(), "receiving shared title: " + sharedTitle);
				Uri sharedUri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
				Log.i(getClass().getSimpleName(), "receiving shared file: " + sharedUri);
				if (eventSink != null) {
					Map<String, String> params = new HashMap<>();
					params.put(TYPE, type);
					params.put(PATH, sharedUri.toString());
					if (!TextUtils.isEmpty(sharedTitle)) {
						params.put(TITLE, sharedTitle);
					}
					if (!intent.hasExtra(Intent.EXTRA_TEXT)) {
						params.put(TEXT, intent.getStringExtra(Intent.EXTRA_TEXT));
					}
					eventSink.success(params);
				}
			}

		} else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
			Log.i(getClass().getSimpleName(), "receiving shared files!");
			ArrayList<Uri> uris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
			if (eventSink != null) {
				Map<String, String> params = new HashMap<>();
				params.put(TYPE, type);
				params.put(IS_MULTIPLE, "true");
				for (int i = 0; i < uris.size(); i++) {
					params.put(Integer.toString(i), uris.get(i).toString());
				}
				eventSink.success(params);
			}

		}
	}
}

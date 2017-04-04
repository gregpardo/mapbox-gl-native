package com.mapbox.mapboxsdk.maps;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.text.Html;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.ArrayAdapter;

import com.mapbox.mapboxsdk.R;
import com.mapbox.mapboxsdk.style.sources.Source;
import com.mapbox.services.android.telemetry.MapboxTelemetry;

import java.util.HashMap;
import java.util.LinkedHashMap;

class AttributionDialogManager implements View.OnClickListener, DialogInterface.OnClickListener {

  private final Context context;
  private final MapboxMap mapboxMap;
  private String[] attributionKeys;
  private HashMap<String, String> attributionMap;

  AttributionDialogManager(@NonNull Context context, @NonNull MapboxMap mapboxMap) {
    this.context = context;
    this.mapboxMap = mapboxMap;
  }

  // Called when someone presses the attribution icon on the map
  @Override
  public void onClick(View view) {
    rebuildAttributionMap();
    showAttributionDialog();
  }

  private void rebuildAttributionMap() {
    attributionMap = new LinkedHashMap<>();
    for (Source source : mapboxMap.getSources()) {
      parseAttribution(source.getAttribution());
    }
    addTelemetryEntryToAttributionMap();
  }

  private void parseAttribution(String attributionSource) {
    if (!TextUtils.isEmpty(attributionSource)) {
      SpannableStringBuilder htmlBuilder = (SpannableStringBuilder) Html.fromHtml(attributionSource);
      URLSpan[] urlSpans = htmlBuilder.getSpans(0, htmlBuilder.length(), URLSpan.class);
      for (URLSpan urlSpan : urlSpans) {
        attributionMap.put(resolveAnchorValue(htmlBuilder, urlSpan), urlSpan.getURL());
      }
    }
  }

  private String resolveAnchorValue(SpannableStringBuilder htmlBuilder, URLSpan urlSpan) {
    int start = htmlBuilder.getSpanStart(urlSpan);
    int end = htmlBuilder.getSpanEnd(urlSpan);
    int length = end - start;
    char[] charKey = new char[length];
    htmlBuilder.getChars(start, end, charKey, 0);
    return String.valueOf(charKey);
  }

  private void addTelemetryEntryToAttributionMap() {
    String telemetryKey = context.getString(R.string.mapbox_telemetrySettings);
    String telemetryLink = context.getString(R.string.mapbox_telemetryLink);
    attributionMap.put(telemetryKey, telemetryLink);
  }

  private void showAttributionDialog() {
    attributionKeys = attributionMap.keySet().toArray(new String[attributionMap.size()]);
    AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.mapbox_AlertDialogStyle);
    builder.setTitle(R.string.mapbox_attributionsDialogTitle);
    builder.setAdapter(new ArrayAdapter<>(context, R.layout.mapbox_attribution_list_item, attributionKeys), this);
    builder.show();
  }

  // Called when someone selects an attribution or telemetry settings
  @Override
  public void onClick(DialogInterface dialog, int which) {
    if (which != attributionKeys.length - 1) {
      showAttributionWebPage(which);
    } else {
      showTelemetryDialog();
    }
  }

  private void showAttributionWebPage(int which) {
    Intent intent = new Intent(Intent.ACTION_VIEW);
    intent.setData(Uri.parse(attributionMap.get(attributionKeys[which])));
    context.startActivity(intent);
  }

  private void showTelemetryDialog() {
    AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.mapbox_AlertDialogStyle);
    builder.setTitle(R.string.mapbox_attributionTelemetryTitle);
    builder.setMessage(R.string.mapbox_attributionTelemetryMessage);
    builder.setPositiveButton(R.string.mapbox_attributionTelemetryPositive, new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        MapboxTelemetry.getInstance().setTelemetryEnabled(true);
        dialog.cancel();
      }
    });
    builder.setNeutralButton(R.string.mapbox_attributionTelemetryNeutral, new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        String url = context.getResources().getString(R.string.mapbox_telemetryLink);
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse(url));
        context.startActivity(intent);
        dialog.cancel();
      }
    });
    builder.setNegativeButton(R.string.mapbox_attributionTelemetryNegative, new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        MapboxTelemetry.getInstance().setTelemetryEnabled(false);
        dialog.cancel();
      }
    });

    builder.show();
  }
}

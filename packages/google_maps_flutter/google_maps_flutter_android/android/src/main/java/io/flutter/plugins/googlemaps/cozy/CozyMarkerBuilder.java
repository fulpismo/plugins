package io.flutter.plugins.googlemaps.cozy;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.BlurMaskFilter;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Typeface;

import com.caverock.androidsvg.SVG;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import android.util.Log;

import androidx.core.content.res.ResourcesCompat;

import io.flutter.plugins.googlemaps.MarkerCache;
import io.flutter.plugins.googlemaps.R;

public class CozyMarkerBuilder {
    private final Typeface font;
    private final float strokeSize;
    private final float shadowBlur;
    private final MarkerCache markerCache;

    private final CozyMarkerElementsBuilder cozyMarkerElementsBuilder;
    private final CozyMarkerInterpolator cozyMarkerInterpolator;

    public CozyMarkerBuilder(Context context) {
        markerCache = new MarkerCache();
        font = ResourcesCompat.getFont(context, R.font.oatmealpro2_semibold);
        strokeSize = CozyMarkerElementsBuilder.getDpFromPx(1.5f);
        shadowBlur = CozyMarkerElementsBuilder.getDpFromPx(4f);

        cozyMarkerElementsBuilder = new CozyMarkerElementsBuilder(font, markerCache, strokeSize);
        cozyMarkerInterpolator = new CozyMarkerInterpolator(font);
    }

    private Paint getTextPaint(float size, int color, float alpha) {
        Paint paint = new Paint();
        paint.setColor(color);
        paint.setTypeface(font);
        paint.setTextSize(size);
        paint.setAntiAlias(true);
        paint.setTextAlign(Paint.Align.LEFT);
        paint.setAlpha((int) (alpha * 255));
        return paint;
    }

    private Paint getShadowPaint(int color, float alpha) {
        Paint paint = new Paint();
        paint.setColor(color);
        paint.setStyle(Paint.Style.FILL);
        paint.setAlpha((int) (alpha * 255));
        paint.setMaskFilter(new BlurMaskFilter(shadowBlur, BlurMaskFilter.Blur.NORMAL));
        paint.setAntiAlias(true);
        return paint;
    }

    private Bitmap getMarkerBitmapFromElements(CozyMarkerElements cozyElements) {
        final CozyMarkerElement canvasObject = cozyElements.canvas;
        final CozyMarkerElement[] labels = cozyElements.labels;
        final CozyMarkerElement[] icons = cozyElements.icons;
        final CozyMarkerElement iconCircle = cozyElements.iconCircle;
        final CozyMarkerElement pointer = cozyElements.pointer;
        final CozyMarkerElement markerBubble = cozyElements.bubble;
        final CozyMarkerElement counterBubble = cozyElements.counterBubble;

        /* start of drawing */
        // creates the marker bitmap
        Bitmap marker = Bitmap.createBitmap((int) Math.ceil(canvasObject.bounds.width()),
                (int) Math.round(canvasObject.bounds.height()), Bitmap.Config.ARGB_8888);

        // create the marker bubble shape
        RectF bubbleShape = markerBubble.bounds;
        final int shapeBorderRadius = Math.round(1000);

        Path bubblePath = new Path();
        bubblePath.addRoundRect(bubbleShape, shapeBorderRadius, shapeBorderRadius, Path.Direction.CW);

        // create the pointer shape
        if (pointer.bounds.height() > 0) {
            Path pointerPath = new Path();
            pointerPath.setFillType(Path.FillType.EVEN_ODD);

            pointerPath.moveTo(pointer.bounds.left, pointer.bounds.top);
            pointerPath.lineTo(pointer.bounds.right, pointer.bounds.top);
            pointerPath.lineTo(pointer.bounds.centerX(), pointer.bounds.bottom);
            pointerPath.lineTo(pointer.bounds.left, pointer.bounds.top);
            pointerPath.close();
            bubblePath.op(bubblePath, pointerPath, Path.Op.UNION);
        }

        Paint fillPaint = new Paint();
        fillPaint.setAntiAlias(true);
        fillPaint.setStyle(Paint.Style.FILL);
        fillPaint.setColor(markerBubble.fillColor);

        Paint strokePaint = new Paint();
        strokePaint.setAntiAlias(true);
        strokePaint.setStyle(Paint.Style.STROKE);
        strokePaint.setColor(markerBubble.strokeColor);
        strokePaint.setStrokeWidth(strokeSize);
        strokePaint.setStrokeCap(Paint.Cap.ROUND);
        
        // create canvas
        Canvas canvas = new Canvas(marker);

        // draws elevation shadow
        if (cozyElements.shadowBubble.alpha != 0) {
            Path shadowPath = new Path();
            shadowPath.addRoundRect(cozyElements.shadowBubble.bounds, shapeBorderRadius, shapeBorderRadius, Path.Direction.CW);
            canvas.drawPath(shadowPath, getShadowPaint(cozyElements.shadowBubble.fillColor, cozyElements.shadowBubble.alpha));
        }

        // draws the bubble with the pointer
        canvas.drawPath(bubblePath, fillPaint);
        canvas.drawPath(bubblePath, strokePaint);
        
        // draws the counter bubble
        if (counterBubble.bounds != null) {
            Path path = new Path();
            path.addRoundRect(counterBubble.bounds, shapeBorderRadius,
                    shapeBorderRadius, Path.Direction.CW);

            fillPaint.setColor(counterBubble.fillColor);
            canvas.drawPath(path, fillPaint);
        }

        // draws the text
        for (CozyMarkerElement label : labels) {
            if (label.data instanceof String
                    && !label.data.toString().isEmpty()) {
                String text = (String) label.data;

                Paint priceMarkerTextStyle = getTextPaint(label.bounds.height(),
                        label.fillColor, label.alpha);
                canvas.drawText(text, label.bounds.left, label.bounds.top, priceMarkerTextStyle);
            }
        }

        // Draw the bigger circle of icon
        if (iconCircle.alpha > 0) {
            Paint circlePaint = new Paint();
            circlePaint.setAntiAlias(true);
            circlePaint.setStyle(Paint.Style.FILL);
            circlePaint.setColor(iconCircle.fillColor);
            circlePaint.setAlpha((int) (iconCircle.alpha * 255));

            float circleX = iconCircle.bounds.centerX();
            float circleY = iconCircle.bounds.centerY();
            float circleRadius = iconCircle.bounds.width() / 2;
            canvas.drawCircle(circleX, circleY, circleRadius, circlePaint);
        }

        // draws the icon if exists
        for (CozyMarkerElement iconElement : cozyElements.icons) {
            if (iconElement.alpha > 0 && iconElement.data != null) {
                Bitmap iconBitmap = (Bitmap) iconElement.data;
                Paint iconPaint = new Paint();
                iconPaint.setAlpha((int) (iconElement.alpha * 255));

                canvas.drawBitmap(iconBitmap, iconElement.bounds.left, iconElement.bounds.top, iconPaint);
            }

        }

        return marker;
    }

    private Bitmap getMarkerBitmap(CozyMarkerData cozyMarkerData) {
        CozyMarkerElements cozyMarkerElements = cozyMarkerElementsBuilder.cozyElementsFromData(cozyMarkerData);
        return getMarkerBitmapFromElements(cozyMarkerElements);
    }

    private Bitmap getInterpolatedMarkerBitmap(CozyMarkerData startMarkerData, CozyMarkerData endMarkerData, float step) {
        CozyMarkerElements startCozyMarkerElements = cozyMarkerElementsBuilder.cozyElementsFromData(startMarkerData);
        CozyMarkerElements endCozyMarkerElements = cozyMarkerElementsBuilder.cozyElementsFromData(endMarkerData);

        final CozyMarkerElements cozyMarkerInterpolatedObjects = cozyMarkerInterpolator.getInterpolatedMarkerObjects(startCozyMarkerElements, endCozyMarkerElements, step);
        return getMarkerBitmapFromElements(cozyMarkerInterpolatedObjects);
    }

    private Bitmap copyOnlyBitmapProperties(Bitmap bitmap) {
        if (bitmap == null)
            return null;
        return bitmap.copy(bitmap.getConfig(), true);
    }

    public Bitmap buildMarker(CozyMarkerData cozyMarkerData) {
        String key = cozyMarkerData.toString();
        final Bitmap bitmap = markerCache.getBitmapFromMemCache(key);
        if (bitmap != null) {
            return bitmap;
        }
        Bitmap marker = getMarkerBitmap(cozyMarkerData);
        markerCache.addBitmapToMemoryCache(key, marker);
        return copyOnlyBitmapProperties(marker);
    }

    public Bitmap buildAnimatedMarker(CozyMarkerData startMarkerData, CozyMarkerData endMarkerData, float step) {
        String key = startMarkerData.toString() + endMarkerData.toString() + step;
        final Bitmap bitmap = markerCache.getBitmapFromMemCache(key);
        if (bitmap != null) {
            return bitmap;
        }
        final Bitmap marker = getInterpolatedMarkerBitmap(startMarkerData, endMarkerData, step);
        markerCache.addBitmapToMemoryCache(key, marker);
        return copyOnlyBitmapProperties(marker);
    }
}
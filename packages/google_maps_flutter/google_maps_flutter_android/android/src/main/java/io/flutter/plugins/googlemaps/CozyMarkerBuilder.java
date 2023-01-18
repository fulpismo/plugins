package io.flutter.plugins.googlemaps;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BlurMaskFilter;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;

import androidx.annotation.NonNull;
import androidx.core.content.res.ResourcesCompat;

public class CozyMarkerBuilder {
    private final int bubblePointSize;
    private final Bitmap defaultClusterMarker;
    private final Paint clusterTextPaint;
    private final Paint bubbleTextPaint;

    CozyMarkerBuilder(Context context) {
        int size = getMarkerSize();
        this.bubblePointSize = size / 6;
        defaultClusterMarker = getClusterBitmap(size);
        clusterTextPaint = setTextPaint(size / 2.9f, context);
        int bubbleFontSize = (int) (size / 3.4);
        bubbleTextPaint = setTextPaint(bubbleFontSize, context);
    }

    @NonNull
    private static Paint setTextPaint(float size, Context context) {
        Paint paint = new Paint();
        paint.setColor(Color.BLACK);
        paint.setTypeface(ResourcesCompat.getFont(context, R.font.oatmealpro2_semibold));
        paint.setTextSize(size);
        paint.setAntiAlias(true);
        paint.setTextAlign(Paint.Align.LEFT);
        return paint;
    }

    @NonNull
    private static Paint getBackgroundColor() {
        Paint paint = new Paint();
        paint.setColor(Color.WHITE);
        paint.setAntiAlias(true);
        return paint;
    }

    @NonNull
    private static Paint getShadowPaint() {
        Paint paint = new Paint();
        paint.setColor(Color.BLACK);
        paint.setStyle(Paint.Style.STROKE);
        paint.setAlpha(15);
        paint.setStrokeWidth(6);
        paint.setMaskFilter(new BlurMaskFilter(8, BlurMaskFilter.Blur.NORMAL));
        paint.setAntiAlias(true);
        return paint;
    }

    private static int getMarkerSize() {
        int baseScreenHeight = 2467;
        int baseMarkerSize = 167;
        int maxMarkerSize = 172;
        int minMarkerSize = 67;

        int physicalPixelHeight = Resources.getSystem().getDisplayMetrics().heightPixels;
        double heightRatio = ((double) (physicalPixelHeight)) / ((double) (baseScreenHeight));
        int proportionalMarkerSize = (int) (baseMarkerSize * heightRatio);

        if (proportionalMarkerSize > maxMarkerSize) {
            return maxMarkerSize;
        } else if (proportionalMarkerSize < minMarkerSize) {
            return minMarkerSize;
        } else {
            return proportionalMarkerSize;
        }
    }

    private static Bitmap getClusterBitmap(int size) {
        Bitmap marker = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(marker);
        canvas.drawCircle(size / 2f, size / 2f, size / 2.2f, getShadowPaint());
        canvas.drawCircle(size / 2f, size / 2f, size / 2.2f, getBackgroundColor());
        return marker;
    }

    private Bitmap addClusterMarkerText(String text) {
        Bitmap marker = Bitmap.createBitmap(this.defaultClusterMarker);
        Rect clusterRect = new Rect();
        clusterTextPaint.getTextBounds(text, 0, text.length(), clusterRect);
        float dx = (marker.getWidth() / 2f) - (clusterRect.width() / 2f) - clusterRect.left;
        float dy = (marker.getHeight() / 2f) + (clusterRect.height() / 2f) - clusterRect.bottom;
        new Canvas(marker).drawText(text, dx, dy, clusterTextPaint);
        return marker;
    }

    private Path getBubblePoint(Bitmap marker) {
        Path pointer = new Path();
        pointer.setFillType(Path.FillType.EVEN_ODD);
        float width = marker.getWidth();
        float height = marker.getHeight() - bubblePointSize;
        pointer.moveTo(width / 2f - bubblePointSize, height);
        pointer.lineTo(width / 2f + bubblePointSize, height);
        pointer.lineTo(width / 2f, height + bubblePointSize);
        pointer.lineTo(width / 2f - bubblePointSize, height);
        pointer.close();
        return pointer;
    }

    private Bitmap addBubbleMarkerText(String text) {
        Rect rect = new Rect();
        bubbleTextPaint.getTextBounds(text, 0, text.length(), rect);

        int padding = this.bubblePointSize * 2;
        int width = rect.width() + padding;
        int height = rect.height() + padding + bubblePointSize;

        RectF bubble = new RectF(0, 0, width, rect.height() + padding);

        Bitmap marker = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(marker);

        double density = Resources.getSystem().getDisplayMetrics().density;
        int borderRadius = (int) (5 * density);
        canvas.drawRoundRect(bubble, borderRadius, borderRadius, getShadowPaint());
        canvas.drawRoundRect(bubble, borderRadius, borderRadius, getBackgroundColor());
        canvas.drawPath(getBubblePoint(marker), getBackgroundColor());

        float dx = (width / 2f) - (rect.width() / 2f) - rect.left;
        float dy = ((rect.height() + padding) / 2f) + (rect.height() / 2f) - rect.bottom;

        canvas.drawText(text, dx, dy, bubbleTextPaint);
        return marker;
    }

    private Bitmap addOvalMarkerText(String text) {
        Rect rect = new Rect();
        bubbleTextPaint.getTextBounds(text, 0, text.length(), rect);

        int padding = this.bubblePointSize * 2;
        int width = rect.width() + padding;
        int height = rect.height() + padding;

        RectF bubble = new RectF(0, 0, width, height);

        Bitmap marker = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

        double density = Resources.getSystem().getDisplayMetrics().density;
        int borderRadius = (int) (5 * density);
        Canvas canvas = new Canvas(marker);
        canvas.drawRoundRect(bubble, borderRadius, borderRadius, getShadowPaint());
        canvas.drawRoundRect(bubble, borderRadius, borderRadius, getBackgroundColor());

        float dx = (width / 2f) - (rect.width() / 2f) - rect.left;
        float dy = ((rect.height() + padding) / 2f) + (rect.height() / 2f) - rect.bottom;

        canvas.drawText(text, dx, dy, bubbleTextPaint);
        return marker;
    }

    public Bitmap buildMarker(String type, String text) {
        switch (type) {
            case "count":
                return addClusterMarkerText(text);
            case "price_legacy":
                return addBubbleMarkerText(text);
            case "price":
                return addOvalMarkerText(text);
            default:
                return null;
        }
    }

}
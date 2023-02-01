package io.flutter.plugins.googlemaps;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.util.LruCache;

import androidx.core.content.res.ResourcesCompat;

public class CozyMarkerBuilder {
    private final int shadowSize = 3;
    private final int priceMarkerTailSize;
    private final int padding;
    private final int size;
    private final Bitmap blankClusterMarker;
    private final Paint clusterTextStyle;
    private final Paint priceMarkerTextStyle;
    private LruCache<String, Bitmap> memoryCache;

    CozyMarkerBuilder(Context context) {
        size = getMarkerSize();
        padding = size / 3;
        priceMarkerTailSize = size / 6;
        blankClusterMarker = getEmptyClusterBitmap(size);
        clusterTextStyle = getTextPaint(size / 3f, context);
        priceMarkerTextStyle = getTextPaint(size / 3.5f, context);
        setMemoryCache();
    }

    private void setMemoryCache() {
        int maxMemory = (int) (Runtime.getRuntime().maxMemory() / 1024);
        int cacheSize = maxMemory / 8;
        memoryCache = new LruCache<String, Bitmap>(cacheSize) {
            @Override
            protected int sizeOf(String key, Bitmap value) {
                return value.getByteCount() / 1024;
            }
        };
    }

    private void addBitmapToMemoryCache(String key, Bitmap bitmap) {
        if (getBitmapFromMemCache(key) == null) {
            memoryCache.put(key, bitmap);
        }
    }

    private Bitmap getBitmapFromMemCache(String key) {
        return memoryCache.get(key);
    }

    private Paint getTextPaint(float size, Context context) {
        Paint paint = new Paint();
        paint.setColor(Color.BLACK);
        paint.setTypeface(ResourcesCompat.getFont(context, R.font.oatmealpro2_semibold));
        paint.setTextSize(size);
        paint.setAntiAlias(true);
        paint.setTextAlign(Paint.Align.LEFT);
        return paint;
    }

    private Paint getMarkerPaint() {
        Paint paint = new Paint();
        paint.setColor(Color.WHITE);
        paint.setAntiAlias(true);
        return paint;
    }

    private Paint getShadowPaint() {
        Paint paint = new Paint();
        paint.setColor(Color.BLACK);
        paint.setStyle(Paint.Style.STROKE);
        paint.setAlpha(15);
        paint.setStrokeWidth(shadowSize);
        paint.setAntiAlias(true);
        return paint;
    }

    private int getMarkerSize() {
        int baseScreenHeight = 2467;
        int baseMarkerSize = 167;
        int maxMarkerSize = 172;
        int minMarkerSize = 67;

        int physicalPixelHeight = Resources.getSystem().getDisplayMetrics().heightPixels;
        double heightRatio = ((double) (physicalPixelHeight)) / ((double) (baseScreenHeight));
        int proportionalMarkerSize = (int) (baseMarkerSize * heightRatio);

        if (proportionalMarkerSize > maxMarkerSize) {
            return maxMarkerSize;
        } else
            return Math.max(proportionalMarkerSize, minMarkerSize);
    }

    private Bitmap getEmptyClusterBitmap(int size) {
        Bitmap marker = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(marker);
        canvas.drawCircle(size / 2f, size / 2f, size / 2.2f, getShadowPaint());
        canvas.drawCircle(size / 2f, size / 2f, (size / 2.2f) - shadowSize, getMarkerPaint());
        return marker;
    }

    private Bitmap getClusterMarkerBitmap(String text) {
        Bitmap marker = Bitmap.createBitmap(this.blankClusterMarker);
        Rect clusterRect = new Rect();
        clusterTextStyle.getTextBounds(text, 0, text.length(), clusterRect);
        float dx = getTextXOffset(marker.getWidth(), clusterRect);
        float dy = getTextYOffset(marker.getHeight(), clusterRect);
        Canvas canvas = new Canvas(marker);
        canvas.drawText(text, dx, dy, clusterTextStyle);
        return marker;
    }

    private Path getPriceMarkerTail(Bitmap marker) {
        Path pointer = new Path();
        pointer.setFillType(Path.FillType.EVEN_ODD);
        float width = marker.getWidth();
        float height = marker.getHeight() - priceMarkerTailSize - shadowSize;
        pointer.moveTo(width / 2f - priceMarkerTailSize, height);
        pointer.lineTo(width / 2f + priceMarkerTailSize, height);
        pointer.lineTo(width / 2f, height + priceMarkerTailSize);
        pointer.lineTo(width / 2f - priceMarkerTailSize, height);
        pointer.close();
        return pointer;
    }

    private Bitmap getPriceMarkerBitmap(String text) {
        Rect rect = new Rect();
        priceMarkerTextStyle.getTextBounds(text, 0, text.length(), rect);

        int width = rect.width() + padding;
        int height = rect.height() + padding;
        int shadowWidth = width + shadowSize;
        int shadowHeight = height + shadowSize;
        Bitmap marker = Bitmap.createBitmap(shadowWidth, shadowHeight + priceMarkerTailSize, Bitmap.Config.ARGB_8888);

        RectF shadow = new RectF(0, 0, shadowWidth, shadowHeight);
        RectF bubble = new RectF(shadowSize, shadowSize, width, height);

        Canvas canvas = new Canvas(marker);

        int borderRadius = 20;
        canvas.drawRoundRect(shadow, borderRadius, borderRadius, getShadowPaint());
        canvas.drawRoundRect(bubble, borderRadius, borderRadius, getMarkerPaint());
        canvas.drawPath(getPriceMarkerTail(marker), getMarkerPaint());

        float dx = getTextXOffset(width, rect);
        float dy = getTextYOffset(height, rect);
        canvas.drawText(text, dx, dy, priceMarkerTextStyle);
        return marker;
    }

    private float getTextYOffset(float markerHeight, Rect rect) {
        return (markerHeight / 2f) + (rect.height() / 2f) - rect.bottom;
    }

    private float getTextXOffset(float markerWidth, Rect rect) {
        return (markerWidth / 2f) - (rect.width() / 2f) - rect.left;
    }

    private Bitmap getRoundedMarkerBitmap(String text) {
        Rect rect = new Rect();
        priceMarkerTextStyle.getTextBounds(text, 0, text.length(), rect);
        int minWidth = Math.max(rect.width(), size / 2);

        int markerWidth = minWidth + padding + shadowSize;
        int markerHeight = rect.height() + padding + shadowSize;
        Bitmap marker = Bitmap.createBitmap(markerWidth, markerHeight, Bitmap.Config.ARGB_8888);

        RectF shadow = new RectF(0, 0, markerWidth, markerHeight);
        RectF shape = new RectF(shadowSize, shadowSize, markerWidth - shadowSize, markerHeight - shadowSize);

        int borderRadius = 40;
        Canvas canvas = new Canvas(marker);
        canvas.drawRoundRect(shadow, borderRadius, borderRadius, getShadowPaint());
        canvas.drawRoundRect(shape, borderRadius, borderRadius, getMarkerPaint());

        float dx = getTextXOffset(markerWidth, rect);
        float dy = getTextYOffset(markerHeight, rect);

        canvas.drawText(text, dx, dy, priceMarkerTextStyle);
        return marker;
    }

    private Bitmap getMarker(String type, String text) {
        switch (type) {
            case "count":
                return getClusterMarkerBitmap(text);
            case "price":
                return getPriceMarkerBitmap(text);
            case "rounded":
                return getRoundedMarkerBitmap(text);
            default:
                return null;
        }
    }

    public Bitmap buildMarker(String type, String text) {
        String key = String.format("%s:%s", type, text);
        final Bitmap bitmap = getBitmapFromMemCache(key);
        if (bitmap != null) {
            return bitmap.copy(bitmap.getConfig(), true);
        }
        Bitmap marker = getMarker(type, text);
        addBitmapToMemoryCache(key, marker);
        return marker.copy(marker.getConfig(), true);
    }
}
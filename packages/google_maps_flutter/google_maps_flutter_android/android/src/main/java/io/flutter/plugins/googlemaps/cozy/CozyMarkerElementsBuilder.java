package io.flutter.plugins.googlemaps.cozy;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Rect;
import android.graphics.Typeface;

import com.caverock.androidsvg.SVG;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import io.flutter.plugins.googlemaps.MarkerCache;

class CozyMarkerElementsBuilder {
    private final Typeface font;
    private final MarkerCache markerCache;
    private final float strokeSize;

    public CozyMarkerElementsBuilder(Typeface font, MarkerCache markerCache, float strokeSize) {
        this.font = font;
        this.markerCache = markerCache;
        this.strokeSize = strokeSize;
    }

    public static float getDpFromPx(float px) {
        return px * Resources.getSystem().getDisplayMetrics().density;
    }

    private float getTextYOffset(float markerHeight, Rect rect) {
        return (markerHeight / 2f) + (rect.height() / 2f) - rect.bottom;
    }

    private float getTextXOffset(float markerWidth, Rect rect) {
        return (markerWidth / 2f) - (rect.width() / 2f) - rect.left;
    }

    private Bitmap getIconBitmap(String svgIcon, int width, int height, int rgbColor) {
        if (svgIcon == null)
            return null;

        String key = String.format("%d%d%d%d", svgIcon.hashCode(), width, height, rgbColor);

        if (key == null)
            return null;

        final Bitmap bitmap = markerCache.getBitmapFromMemCache(key);
        if (bitmap != null) {
            return bitmap;
        }

        try {
            //Needed this because svg doesn't scale if there is fixed width and height
            String widthPattern = "(width=\")(.+?)(\")";
            String heightPattern = "(height=\")(.+?)(\")";

            Matcher widthMatcher = Pattern.compile(widthPattern).matcher(svgIcon);
            Matcher heightMatcher = Pattern.compile(heightPattern).matcher(svgIcon);

            String finalSvgIcon = svgIcon.replaceAll(widthPattern, "");
            finalSvgIcon = finalSvgIcon.replaceAll(heightPattern, "");

            finalSvgIcon = recolorSvg(finalSvgIcon, rgbColor);

            SVG svg = SVG.getFromString(finalSvgIcon);
            if (widthMatcher.find() && heightMatcher.find()) {
                svg.setDocumentViewBox(0, 0, Integer.parseInt(widthMatcher.group(2)), Integer.parseInt(heightMatcher.group(2)));
            }

            Bitmap iconBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(iconBitmap);
            svg.renderToCanvas(canvas, new RectF(0, 0, width, height));

            markerCache.addBitmapToMemoryCache(svgIcon, iconBitmap);
            return iconBitmap;
        } catch (Exception e) {
        }

        return null;
    }

    private String recolorSvg(String originalSvg, int rgbColor) {
        String hexColor = String.format("#%06X", (0xFFFFFF & rgbColor));
        return originalSvg.replaceAll("(fill=\")(.+?)(\")", "fill=\"" + hexColor + "\"");
    }

    private boolean isMiniMarker(String size) {
        return size.equals("mini") || size.equals("miniDot");
    }

    public CozyMarkerElements cozyElementsFromData(CozyMarkerData markerData) {
        
        String text = markerData.label;
        String counterText = markerData.counter;
        String icon = markerData.icon;

        boolean hasPointer = markerData.hasPointer;
        boolean hasCounter = counterText != null && !counterText.isEmpty();
        boolean hasElevation = markerData.hasElevation;
        boolean hasIcon = icon != null && !icon.isEmpty();

        if (isMiniMarker(markerData.size)) {
            text = "";
            counterText = null;
            hasPointer = false;
            hasCounter = false;
            hasIcon = false;
        }

        /* setting colors */
        final int defaultMarkerColor = Color.WHITE;
        final int defaultTextColor = Color.BLACK;
        final int defaultStrokeColor = Color.rgb(215, 215, 221);
        final int defaultIconCircleColor = Color.rgb(245, 245, 247);

        final int defaultIconColor = Color.BLACK;
    
        final int defaultCounterBubbleColor = Color.rgb(245, 245, 247);
        final int selectedMarkerColor = Color.rgb(57, 87, 189);
        final int selectedTextColor = Color.WHITE;
        final int selectedIconCircleColor = Color.WHITE;
        final int selectedCounterBubbleColor = Color.rgb(245, 245, 247);

        final int visualizedMarkerColor = Color.rgb(228, 228, 232);
        final int visualizedTextColor = Color.BLACK;
        final int visualizedStrokeColor = Color.rgb(185, 185, 195);
        final int visualizedIconCircleColor = Color.WHITE;
        final int visualizedCounterBubbleColor = Color.rgb(245, 245, 247);

        final int specialIconCircleColor = Color.rgb(240, 243, 255);
        final int specialIconColor = Color.rgb(57, 87, 189);


        int markerColor = defaultMarkerColor;
        int textColor = defaultTextColor;
        int counterTextColor = defaultTextColor;
        int strokeColor = defaultStrokeColor;
        int iconCircleColor = defaultIconCircleColor;
        int iconColor = defaultIconColor;
        int counterBubbleColor = defaultCounterBubbleColor;

        if (markerData.isVisualized) {
            markerColor = visualizedMarkerColor;
            textColor = visualizedTextColor;
            strokeColor = visualizedStrokeColor;
            iconCircleColor = visualizedIconCircleColor;
            counterBubbleColor = visualizedCounterBubbleColor;
        }
        if (markerData.isSelected) {
            markerColor = selectedMarkerColor;
            textColor = selectedTextColor;
            strokeColor = defaultStrokeColor;
            iconCircleColor = selectedIconCircleColor;
            counterBubbleColor = selectedCounterBubbleColor;
        }
        if (markerData.variant.equals("special") &&
                (!markerData.isVisualized || markerData.isSelected)) {
            iconCircleColor = specialIconCircleColor;
            iconColor = specialIconColor;
        }

        if (isMiniMarker(markerData.size)) {
           strokeColor = Color.rgb(175, 179, 165);
        }

        /* setting constants */
        // setting global constants
        final float paddingVertical = getDpFromPx(12);
        final float paddingHorizontal = getDpFromPx(11.5f);
        final float minMarkerWidth = getDpFromPx(40);
        final float strokeSize = getDpFromPx(1.5f);
        final float elevation = hasElevation ? getDpFromPx(5f) : 0;
        final float totalStrokeSize = strokeSize + elevation;
        final float shadowDisplacement = getDpFromPx(2f);
        final float miniPinRadius = getDpFromPx(4f);
        final float miniPinWidth = getDpFromPx(14);

        // setting constants for counter
        final float counterBubblePadding = getDpFromPx(6);

        // setting constants for pointer
        final float pointerWidth = getDpFromPx(7);
        final float pointerHeight = getDpFromPx(6);

        // setting constants for icon
        final float iconSize = getDpFromPx(16);
        final float iconCircleSize = getDpFromPx(24);
        final float iconLeftPadding = getDpFromPx(5);
        final float iconRightPadding = getDpFromPx(3);

        /* setting variables */
        // gets the text size based on the font
        Rect textBounds = new Rect();
        Rect counterTextBounds = new Rect();

        float textSize = getDpFromPx(12f);
        Paint textPaint = new Paint();
        textPaint.setTypeface(font);
        textPaint.setTextSize(textSize);
        textPaint.setAntiAlias(true);
        textPaint.setTextAlign(Paint.Align.LEFT);

        textPaint.getTextBounds(text, 0, text.length(), textBounds);
        if (hasCounter) {
            textPaint.getTextBounds(counterText, 0, counterText.length(), counterTextBounds);
        }

        // getting icon bitmap
        Bitmap iconBitmap = hasIcon ? getIconBitmap(markerData.icon, (int) Math.round(iconSize),
                (int) Math.round(iconSize), iconColor) : null;

        // set the marker height as the string height with space for padding and stroke
        float markerHeight = textBounds.height() + (2f * paddingVertical) + 2f * strokeSize;

        // bubble shape properties which used in marker width
        float bubbleShapeHeight = markerHeight - strokeSize;
        float counterBubbleShapeHeight = bubbleShapeHeight - (2f * counterBubblePadding);

        // counterSummaryWidth to be used on markerWidth
        float counterSummaryWidth = hasCounter ?
                Math.max(counterTextBounds.width() + (2f * counterBubblePadding),
                        counterBubbleShapeHeight) : 0;

        // additionalIconWidth to be used on markerWidth
        float iconAdditionalWidth = iconBitmap != null ? iconCircleSize + iconRightPadding : 0;

        // pointerSize to be used on bitmap creation
        float pointerSize = (hasPointer ? pointerHeight : 0);

        // setting marker width with a minimum width in case the string size is below the minimum
        float markerWidth = textBounds.width() + counterSummaryWidth + (2f * paddingHorizontal)
                + (2f * strokeSize) + iconAdditionalWidth;
        if (markerWidth < minMarkerWidth) {
            markerWidth = minMarkerWidth;
        }

        if(isMiniMarker(markerData.size)) {
            if(markerData.size.equals("mini")) {
                markerHeight = miniPinRadius * 2 + (2f * strokeSize);
                markerWidth = miniPinWidth + (2f * strokeSize);
            }
            if(markerData.size.equals("miniDot")) {
                markerHeight = miniPinRadius * 2 + (2f * strokeSize);
                markerWidth = miniPinRadius * 2 + (2f * strokeSize);
            }
            bubbleShapeHeight = markerHeight - strokeSize;
        }

        float canvasWidth = markerWidth + elevation;
        float canvasHeight = markerHeight + elevation + pointerSize;

        // marker bubble coordinates
        float bubbleShapeX = totalStrokeSize / 2f;
        float bubbleShapeY = totalStrokeSize / 2f;
        float bubbleShapeWidth = markerWidth - strokeSize;

        // counter bubble coordinates
        float counterBubbleShapeX = canvasWidth - totalStrokeSize
                - counterSummaryWidth - counterBubblePadding;
        float counterBubbleShapeY = counterBubblePadding + totalStrokeSize / 2f;

        // counter text coordinates and size
        float counterTextWidth = counterTextBounds.width();
        float counterTextHeight = textSize;
        float counterTextDx = counterBubbleShapeX +
                (counterSummaryWidth / 2f) - (counterTextWidth / 2f);
        float counterTextDy = getTextYOffset(canvasHeight - pointerSize, counterTextBounds);

        // other important variables
        float middleOfMarkerY = (bubbleShapeHeight / 2f) + totalStrokeSize / 2f;

        // text coordinates
        float textDx = getTextXOffset(canvasWidth, textBounds) + iconAdditionalWidth / 2f
                - counterSummaryWidth / 2f;
        float textDy = getTextYOffset(canvasHeight - pointerSize, textBounds);
        float textHeight = textSize;
        float textWidth = textBounds.width();

        // Icon coordinates
        float iconX = iconLeftPadding + totalStrokeSize + (iconCircleSize - iconSize) / 2f;
        float iconY = (bubbleShapeHeight / 2f) - (iconSize / 2f) + totalStrokeSize / 2f;
        float iconWidth = iconSize;
        float iconHeight = iconSize;

        // Icon circle coordinates
        float circleX = iconLeftPadding + totalStrokeSize + iconCircleSize / 2f - iconCircleSize / 2f;
        float circleY = middleOfMarkerY - iconCircleSize / 2f;
        float circleWidth = iconCircleSize;
        float circleHeight = iconCircleSize;

        // Pointer coordinates
        float pointerX = canvasWidth / 2f - pointerWidth;
        float pointerY = canvasHeight - pointerSize - totalStrokeSize + elevation / 2f;

        float shadowAlpha = hasElevation ? isMiniMarker(markerData.size) ? 0.2f : 0.15f : 0.0f;

        return new CozyMarkerElements(
                // Canvas
                new CozyMarkerElement(
                        new RectF(0, 0, canvasWidth, canvasHeight)
                ),
                // Bubbles
                new CozyMarkerElement(
                        new RectF(bubbleShapeX, bubbleShapeY, bubbleShapeX + bubbleShapeWidth, bubbleShapeY + bubbleShapeHeight),
                        markerColor,
                        strokeColor
                ),
                // Shadow bubble
                new CozyMarkerElement(
                        new RectF(bubbleShapeX, bubbleShapeY + shadowDisplacement, bubbleShapeX + bubbleShapeWidth, bubbleShapeY + bubbleShapeHeight + shadowDisplacement),
                        Color.BLACK,
                        shadowAlpha
                ),
                // Counter bubble
                new CozyMarkerElement(
                        hasCounter ? new RectF(counterBubbleShapeX, counterBubbleShapeY, counterBubbleShapeX + counterSummaryWidth, counterBubbleShapeY + counterBubbleShapeHeight) : null,
                        counterBubbleColor,
                        defaultStrokeColor
                ),
                // Labels
                new CozyMarkerElement[]{
                        new CozyMarkerElement(
                                new RectF(textDx, textDy, textDx + textWidth, textDy + textHeight),
                                textColor,
                                1.0f,
                                text
                        ),
                        new CozyMarkerElement(
                                new RectF(counterTextDx, counterTextDy, counterTextDx + counterTextWidth, counterTextDy + counterTextHeight),
                                counterTextColor,
                                1.0f,
                                counterText
                        ),
                },
                // Icon
                new CozyMarkerElement[]{
                        new CozyMarkerElement(
                                new RectF(iconX, iconY, iconX + iconWidth, iconY + iconHeight),
                                iconColor,
                                iconBitmap == null ? 0.0f : 1.0f,
                                iconBitmap == null ? null : iconBitmap
                        ),
                },
                // IconCircle
                new CozyMarkerElement(
                        new RectF(circleX, circleY, circleX + circleWidth, circleY + circleHeight),
                        iconCircleColor,
                        iconBitmap == null ? 0.0f : 1.0f
                ),
                // Pointer
                new CozyMarkerElement(
                        new RectF(pointerX, pointerY, pointerX + 2 * pointerWidth, pointerY + pointerSize),
                        markerColor,
                        strokeColor
                )
        );
    }
}
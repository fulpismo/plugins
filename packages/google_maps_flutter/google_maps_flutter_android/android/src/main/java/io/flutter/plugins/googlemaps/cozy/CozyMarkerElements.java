package io.flutter.plugins.googlemaps.cozy;

public class CozyMarkerElements {
    public final CozyMarkerElement canvas;
    public final CozyMarkerElement bubble;
    public final CozyMarkerElement shadowBubble;
    public final CozyMarkerElement[] labels;
    public final CozyMarkerElement[] icons;
    public final CozyMarkerElement iconCircle;
    public final CozyMarkerElement pointer;
    public final CozyMarkerElement counterBubble;

    public CozyMarkerElements(CozyMarkerElement canvas, CozyMarkerElement bubble, CozyMarkerElement shadowBubble, CozyMarkerElement counterBubble, CozyMarkerElement[] labels, CozyMarkerElement[] icons, CozyMarkerElement iconCircle, CozyMarkerElement pointer) {
        this.canvas = canvas;
        this.shadowBubble = shadowBubble;
        this.bubble = bubble;
        this.counterBubble = counterBubble;
        this.labels = labels;
        this.icons = icons;
        this.iconCircle = iconCircle;
        this.pointer = pointer;
    }

    @Override
    public String toString() {
        return canvas.toString() + shadowBubble.toString() + bubble.toString() + counterBubble.toString() + labels.toString() + icons.toString() + iconCircle.toString() + pointer.toString();
    }
}
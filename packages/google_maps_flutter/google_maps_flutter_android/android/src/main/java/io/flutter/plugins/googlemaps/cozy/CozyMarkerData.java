package io.flutter.plugins.googlemaps.cozy;

public class CozyMarkerData {
    public final String label;
    public final String icon;
    public final String counter;
    public final boolean hasPointer;
    public final boolean hasElevation;
    public final boolean isSelected;
    public final boolean isVisualized;
    public final String state;
    public final String variant;
    public final String size;
    public final boolean isAnimated;

    public CozyMarkerData(String label, String icon, String counter, boolean hasPointer, boolean hasElevation, boolean isSelected, boolean isVisualized, String state, String variant, String size, boolean isAnimated) {
        this.label = label;
        this.icon = icon;
        this.counter = counter;
        this.hasPointer = hasPointer;
        this.hasElevation = hasElevation;
        this.isSelected = isSelected;
        this.isVisualized = isVisualized;
        this.state = state;
        this.variant = variant;
        this.size = size;
        this.isAnimated = isAnimated;
    }

    @Override
    public String toString() {
        return label + counter + (icon != null ? icon.hashCode() : "") + hasPointer + hasElevation + isSelected + isVisualized + state + variant + size + isAnimated;
    }

    @Override
    public boolean equals(Object o) {
        return this.toString().equals(o.toString());
    }
}
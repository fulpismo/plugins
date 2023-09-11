package io.flutter.plugins.googlemaps;

public class CozyMarkerData {
    public final String label;
    public final String icon;
    public final String chevronIcon;
    public final boolean hasPointer;
    public final boolean isSelected;
    public final boolean isVisualized;
    public final String state;
    public final String variant;
    public final String size;

    public CozyMarkerData(String label, String icon, String chevronIcon, boolean hasPointer, boolean isSelected, boolean isVisualized, String state, String variant, String size) {
        this.label = label;
        this.icon = icon;
        this.chevronIcon = chevronIcon;
        this.hasPointer = hasPointer;
        this.isSelected = isSelected;
        this.isVisualized = isVisualized;
        this.state = state;
        this.variant = variant;
        this.size = size;
    }
    
    @Override
    public String toString() {
        return label + icon + chevronIcon + hasPointer + isSelected + isVisualized + state + variant + size;
    }
}
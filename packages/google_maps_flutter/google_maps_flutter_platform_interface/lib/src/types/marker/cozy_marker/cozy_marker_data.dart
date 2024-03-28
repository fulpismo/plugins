import 'package:flutter/foundation.dart' show immutable;

/// CozyMarkerData is the payload necessary to describe all attributes of a CozyMarker.
/// It follows the same properties described on cozy MapPin component.
@immutable
class CozyMarkerData {
  /// Creates CozyMarkerData payload.
  const CozyMarkerData({
    required this.label,
    this.counter,
    this.icon,
    this.isVisualized = false,
    this.isSelected = false,
    this.hasPointer = false,
    this.hasElevation = false,
    this.state = CozyMarkerState.defaultState,
    this.variant = CozyMarkerVariant.defaultVariant,
    this.size = CozyMarkerSize.small,
    this.isAnimated = false,
  });

  /// Label of the marker
  final String label;

  /// Icon of the marker in svg format.
  final String? icon;

  /// Counter label of the marker.
  final String? counter;

  /// Wether marker is in selected state or not.
  final bool isSelected;

  /// Wether marker is visualized or not.
  final bool isVisualized;

  /// Wether marker has a little pointer below it or not.
  final bool hasPointer;

  /// Wether marker has elevation or not.
  final bool hasElevation;

  /// State of the marker
  /// It can have either default or pressed state.
  final CozyMarkerState state;

  /// Variant can be default or special. It affects specially the icon of the marker.
  final CozyMarkerVariant variant;

  /// Size can be:
  /// - Mini
  /// - MiniDot
  /// - Small
  /// - Big
  final CozyMarkerSize size;

  /// Wether marker has animated transitions or not.
  final bool isAnimated;

  /// Converts this object to something serializable in JSON.
  Object toJson() {
    final Map<String, Object> json = <String, Object>{};

    void addIfPresent(String fieldName, Object? value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('label', label);
    addIfPresent('isSelected', isSelected);
    addIfPresent('isVisualized', isVisualized);
    addIfPresent('hasPointer', hasPointer);
    addIfPresent('hasElevation', hasElevation);
    addIfPresent('state', state.name);
    addIfPresent('variant', variant.name);
    addIfPresent('size', size.name);
    addIfPresent('icon', icon);
    addIfPresent('counter', counter);
    addIfPresent('isAnimated', isAnimated);

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CozyMarkerData &&
        label == other.label &&
        isSelected == other.isSelected &&
        isVisualized == other.isVisualized &&
        hasPointer == other.hasPointer &&
        hasElevation == other.hasElevation &&
        state == other.state &&
        variant == other.variant &&
        size == other.size &&
        icon == other.icon &&
        counter == other.counter &&
        isAnimated == other.isAnimated;
  }

  @override
  int get hashCode => Object.hash(label, isSelected,
   isVisualized, hasPointer, hasElevation,
      state, variant, size, icon, counter, isAnimated);

  @override
  String toString() {
    return 'CozyMarkerData{ label: $label, isSelected: $isSelected, isVisualized: $isVisualized, hasPointer: $hasPointer, state: ${state.name}, hasElevation:${hasElevation} variant: ${variant.name}, size: ${size.name}, icon: $icon, isAnimated: $isAnimated, counter: $counter }';
  }
}

/// State of the marker. Can be:
/// - defaultState
/// - pressedState
enum CozyMarkerState {
  /// Default state of the marker.
  defaultState,

  /// pressedState of the marker.
  // TODO(pietroid): Disabled because it is not implemented on native side yet. Need to implement it on the future.
  // pressedState,
}

/// Variant of the marker. Can be:
/// - defaultVariant
/// - special
enum CozyMarkerVariant {
  /// Default variant of the marker.
  defaultVariant,

  /// Special variant of the marker.
  special,
}

/// Size of the marker. Can be:
/// - small
/// - big
enum CozyMarkerSize {
  /// Mini pin
  mini,

  /// Mini pin as a dot
  miniDot,

  /// Small size of the marker.
  small,

  /// Big size of the marker.
  // TODO(pietroid): Disabled because it is not implemented on native side yet. Need to implement it on the future.
  // big,
}
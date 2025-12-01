import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive helper class for adaptive UI
class ResponsiveHelper {
  final BuildContext context;
  final BoxConstraints constraints;

  ResponsiveHelper(this.context, this.constraints);

  /// Factory constructor using MediaQuery
  factory ResponsiveHelper.of(BuildContext context) {
    return ResponsiveHelper(
      context,
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
    );
  }

  /// Get current device type
  DeviceType get deviceType {
    final width = constraints.maxWidth;
    if (width < ResponsiveBreakpoints.mobile) return DeviceType.mobile;
    if (width < ResponsiveBreakpoints.tablet) return DeviceType.tablet;
    if (width < ResponsiveBreakpoints.desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Check if device is mobile
  bool get isMobile => deviceType == DeviceType.mobile;

  /// Check if device is tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Check if device is desktop
  bool get isDesktop =>
      deviceType == DeviceType.desktop ||
      deviceType == DeviceType.largeDesktop;

  /// Check if device is small (mobile or small tablet)
  bool get isSmall => constraints.maxWidth < ResponsiveBreakpoints.tablet;

  /// Get responsive value based on device type
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive font size
  double fontSize(double baseSize) {
    final scaleFactor = value<double>(
      mobile: 0.85,
      tablet: 0.95,
      desktop: 1.0,
      largeDesktop: 1.1,
    );
    return baseSize * scaleFactor;
  }

  /// Get responsive spacing
  double spacing(double baseSpacing) {
    final scaleFactor = value<double>(
      mobile: 0.75,
      tablet: 0.85,
      desktop: 1.0,
      largeDesktop: 1.15,
    );
    return baseSpacing * scaleFactor;
  }

  /// Get responsive padding
  EdgeInsets padding(EdgeInsets basePadding) {
    final scaleFactor = value<double>(
      mobile: 0.75,
      tablet: 0.85,
      desktop: 1.0,
      largeDesktop: 1.15,
    );
    return basePadding * scaleFactor;
  }

  /// Get sidebar width
  double get sidebarWidth => value<double>(
        mobile: 280,
        tablet: 280,
        desktop: 280,
        largeDesktop: 320,
      );

  /// Get top bar height
  double get topBarHeight => value<double>(
        mobile: 56,
        tablet: 64,
        desktop: 64,
        largeDesktop: 72,
      );

  /// Get data table column spacing
  double get tableColumnSpacing => value<double>(
        mobile: 4,
        tablet: 6,
        desktop: 8,
        largeDesktop: 10,
      );

  /// Get data table row height
  double get tableRowHeight => value<double>(
        mobile: 44,
        tablet: 48,
        desktop: 52,
        largeDesktop: 56,
      );

  /// Get checkbox size
  double get checkboxSize => value<double>(
        mobile: 24,
        tablet: 22,
        desktop: 20,
        largeDesktop: 22,
      );

  /// Get icon size for small icons
  double get smallIconSize => value<double>(
        mobile: 14,
        tablet: 16,
        desktop: 18,
        largeDesktop: 20,
      );

  /// Get icon size for medium icons
  double get mediumIconSize => value<double>(
        mobile: 18,
        tablet: 20,
        desktop: 20,
        largeDesktop: 22,
      );

  /// Get icon size for large icons
  double get largeIconSize => value<double>(
        mobile: 20,
        tablet: 22,
        desktop: 24,
        largeDesktop: 26,
      );

  /// Get grid column count
  int get gridColumnCount => value<int>(
        mobile: 2,
        tablet: 3,
        desktop: 5,
        largeDesktop: 6,
      );

  /// Get content max width
  double? get contentMaxWidth => value<double?>(
        mobile: null,
        tablet: null,
        desktop: null,
        largeDesktop: 1920,
      );
}

/// Extension on BuildContext for easy access
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper.of(this);
}

import 'package:flutter/material.dart';
import 'package:webview_integrations/color_config.dart';

class ButtonWidget extends StatelessWidget {
  final Color? textColor, borderColor, backgroundColor;
  final Function()? onTap;
  final Widget? child;
  final double? elevation;
  final bool? isLoading, isDisabled;
  final String? text;
  final double? height, width;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final Gradient? backgroundGradient;

  const ButtonWidget({
    super.key,
    this.child,
    this.onTap,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.elevation,
    this.isLoading,
    this.isDisabled,
    this.text,
    this.height,
    this.width,
    this.borderRadius,
    this.padding,
    this.style,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: _backgroundGradient,
        color: _backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: () {
          if (isDisabled == true) {
            return;
          }

          if (onTap == null) {
            return;
          }

          if (isLoading == true) {
            return;
          }

          onTap!();
        },
        style: ButtonStyle(
          shape: _shape,
          padding: _padding,
          elevation: WidgetStateProperty.all(elevation ?? 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.all(
            Colors.transparent,
          ),
        ),
        child: buttonChild,
      ),
    );
  }

  Color? get _backgroundColor {
    if (isDisabled == true) {
      return ColorConfig.disable;
    }

    if (backgroundColor != null) {
      return backgroundColor!;
    }

    return null;
  }

  Gradient? get _backgroundGradient {
    if (backgroundColor != null) {
      return null;
    }

    if (backgroundGradient != null) {
      return backgroundGradient;
    }

    return ColorConfig.horizontalGradient;
  }

  Widget? get buttonChild {
    if (isLoading == true) {
      return SizedBox(
        height: 23,
        width: 23,
        child: CircularProgressIndicator(
          color: textColor ?? Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    if (child != null) {
      return child;
    }

    TextStyle? style = this.style;

    style ??= TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textColor ?? Colors.white,
    );

    return Text(
      text ?? '',
      style: style,
      textAlign: TextAlign.center,
    );
  }

  WidgetStateProperty<OutlinedBorder?>? get _shape {
    BorderSide side = BorderSide.none;
    BorderRadiusGeometry? borderRadius = this.borderRadius;

    if (borderColor != null) {
      side = BorderSide(
        color: borderColor!,
      );
    }

    if (borderRadius != null) {
      return WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: side,
        ),
      );
    }

    borderRadius ??= BorderRadius.zero;

    return WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: side,
      ),
    );
  }

  WidgetStateProperty<EdgeInsetsGeometry?>? get _padding {
    EdgeInsetsGeometry? padding = this.padding;

    padding ??= const EdgeInsets.symmetric(
      vertical: 9,
    );

    return WidgetStateProperty.all(padding);
  }
}

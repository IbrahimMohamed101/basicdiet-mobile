import 'package:basic_diet/presentation/resources/color_manager.dart';
import 'package:basic_diet/presentation/resources/styles_manager.dart';
import 'package:basic_diet/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonWidget extends StatelessWidget {
  final double radius, width, height;
  final String text;
  final void Function()? onTap;
  final Color color;
  final Color textColor;
  final Color? disabledColor;
  final Color? disabledTextColor;

  const ButtonWidget({
    super.key,
    required this.radius,
    this.width = double.infinity,
    this.height = AppSize.s50,
    this.color = ColorManager.greenPrimary,
    required this.text,
    this.onTap,
    this.textColor = ColorManager.whiteColor,
    this.disabledColor,
    this.disabledTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final backgroundColor = isEnabled
        ? color
        : (disabledColor ?? ColorManager.state.disabledSurface);
    final foregroundColor = isEnabled
        ? textColor
        : (disabledTextColor ?? ColorManager.state.disabled);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius.r),
        splashColor: ColorManager.brand.primaryTint,
        highlightColor: ColorManager.brand.primaryTint,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: height.h,
          width: width.w,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius.r),
          ),
          child: Center(
            child: Text(
              text,
              style: getBoldTextStyle(
                color: foregroundColor,
                fontSize: AppSize.s18.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

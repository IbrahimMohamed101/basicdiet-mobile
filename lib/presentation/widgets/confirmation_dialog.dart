import 'package:flutter/material.dart';
import 'package:basic_diet/presentation/resources/color_manager.dart';
import 'package:basic_diet/presentation/resources/font_manager.dart';
import 'package:basic_diet/presentation/resources/styles_manager.dart';
import 'package:basic_diet/presentation/resources/values_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    this.confirmColor = ColorManager.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManager.background.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s16),
      ),
      title: Text(
        title,
        style: getRegularTextStyle(
          color: ColorManager.text.primary,
          fontSize: FontSizeManager.s18.sp,
        ),
      ),
      content: Text(
        body,
        style: getRegularTextStyle(
          color: ColorManager.text.secondary,
          fontSize: FontSizeManager.s14.sp,
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        AppPadding.p16.w,
        0,
        AppPadding.p16.w,
        AppPadding.p16.h,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p12.h),
                  side: BorderSide(color: ColorManager.border.defaultColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                ),
                child: Text(
                  cancelLabel,
                  style: getRegularTextStyle(
                    color: ColorManager.text.primary,
                    fontSize: FontSizeManager.s14.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSize.s8.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s8),
                  ),
                ),
                child: Text(
                  confirmLabel,
                  style: getRegularTextStyle(
                    color: ColorManager.text.inverse,
                    fontSize: FontSizeManager.s14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

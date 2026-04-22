import 'package:basic_diet/presentation/resources/color_manager.dart';
import 'package:basic_diet/presentation/resources/font_manager.dart';
import 'package:basic_diet/presentation/resources/strings_manager.dart';
import 'package:basic_diet/presentation/resources/styles_manager.dart';
import 'package:basic_diet/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class MealPlannerProgressIndicator extends StatelessWidget {
  final int selectedMeals;
  final int totalMeals;
  final int premiumLeft;
  final int premiumPending;
  final double paymentAmount;

  const MealPlannerProgressIndicator({
    super.key,
    required this.selectedMeals,
    required this.totalMeals,
    required this.premiumLeft,
    required this.premiumPending,
    required this.paymentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isAllSelected = totalMeals > 0 && selectedMeals >= totalMeals;
    final activeColor = isAllSelected
        ? ColorManager.brand.primary
        : ColorManager.brand.primaryHover;
    final hasPendingPayment = premiumPending > 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32.w,
                    width: 32.w,
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: activeColor, size: 18.w),
                  ),
                  Gap(AppSize.s12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$selectedMeals ${Strings.of.tr()} $totalMeals ${Strings.meals.tr()} ${Strings.selected.tr()}",
                          style: getRegularTextStyle(
                            color: ColorManager.black101828,
                            fontSize: FontSizeManager.s14.sp,
                          ),
                        ),
                        Gap(8.h),
                        Row(
                          children: List.generate(totalMeals, (index) {
                            final isFilled = index < selectedMeals;
                            return Container(
                              width: 20.w,
                              height: 4.h,
                              margin: EdgeInsets.only(right: 6.w),
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? activeColor
                                    : ColorManager.background.subtle,
                                borderRadius: BorderRadius.circular(99.r),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(AppSize.s12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: ColorManager.brand.accentSoft,
                border: Border.all(color: ColorManager.brand.accentBorder),
                borderRadius: BorderRadius.circular(AppSize.s12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: ColorManager.brand.accent,
                    size: 18.w,
                  ),
                  Gap(6.w),
                  Text(
                    "$premiumLeft ${Strings.premiumMealsText.tr()} ${Strings.left.tr()}",
                    style: getBoldTextStyle(
                      color: ColorManager.brand.accent,
                      fontSize: FontSizeManager.s12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (hasPendingPayment) ...[
          Gap(AppSize.s12.h),
          _PendingPaymentBanner(
            premiumPending: premiumPending,
            paymentAmount: paymentAmount,
          ),
        ],
      ],
    );
  }
}

class _PendingPaymentBanner extends StatelessWidget {
  final int premiumPending;
  final double paymentAmount;

  const _PendingPaymentBanner({
    required this.premiumPending,
    required this.paymentAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPadding.p12.w),
      decoration: BoxDecoration(
        color: ColorManager.state.warningSurface,
        border: Border.all(color: ColorManager.state.warningBorder),
        borderRadius: BorderRadius.circular(AppSize.s12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ColorManager.state.warning,
            size: 20.w,
          ),
          Gap(AppSize.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.paymentRequired.tr(),
                  style: getBoldTextStyle(
                    color: ColorManager.state.warningEmphasis,
                    fontSize: FontSizeManager.s14.sp,
                  ),
                ),
                Gap(4.h),
                Text(
                  "${Strings.youSelected.tr()} $premiumPending ${Strings.extraPremiumMeals.tr()}",
                  style: getRegularTextStyle(
                    color: ColorManager.state.warningEmphasis,
                    fontSize: FontSizeManager.s12.sp,
                  ),
                ),
                Text(
                  "${Strings.totalAmount.tr()}: ${paymentAmount.toStringAsFixed(2)} ${Strings.sar.tr()}",
                  style: getBoldTextStyle(
                    color: ColorManager.state.warningEmphasis,
                    fontSize: FontSizeManager.s10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

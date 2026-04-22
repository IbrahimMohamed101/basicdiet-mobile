import 'package:basic_diet/app/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:basic_diet/presentation/resources/color_manager.dart';
import 'package:basic_diet/presentation/resources/font_manager.dart';
import 'package:basic_diet/presentation/resources/strings_manager.dart';
import 'package:basic_diet/presentation/resources/styles_manager.dart';
import 'package:basic_diet/presentation/resources/values_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:basic_diet/presentation/plans/manage_subscription/skip/skip_days_bloc.dart';
import 'package:basic_diet/presentation/plans/manage_subscription/skip/skip_days_event.dart';
import 'package:basic_diet/presentation/plans/manage_subscription/skip/skip_days_state.dart';
import 'package:basic_diet/presentation/widgets/button_widget.dart';

enum SkipTypeSelection { singleDay, dateRange }

class SkipDaysScreen extends StatefulWidget {
  final String subscriptionId;
  final int skipDaysUsed;
  final int skipDaysLimit;
  final int remainingSkipDays;

  const SkipDaysScreen({
    super.key,
    required this.subscriptionId,
    required this.skipDaysUsed,
    required this.skipDaysLimit,
    required this.remainingSkipDays,
  });

  @override
  State<SkipDaysScreen> createState() => _SkipDaysScreenState();
}

class _SkipDaysScreenState extends State<SkipDaysScreen> {
  SkipTypeSelection _skipType = SkipTypeSelection.dateRange;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        initSkipDaysModule();
        return instance<SkipDaysBloc>();
      },
      child: BlocConsumer<SkipDaysBloc, SkipDaysState>(
        listener: (context, state) {
          if (state is SkipDaysSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorManager.state.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is SkipDaysError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorManager.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorManager.background.app,
            appBar: AppBar(
              backgroundColor: ColorManager.background.surface,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: ColorManager.text.primary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                Strings.skipDays.tr(),
                style: getRegularTextStyle(
                  color: ColorManager.text.primary,
                  fontSize: FontSizeManager.s20.sp,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: ColorManager.border.defaultColor,
                  height: 1.0,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLimitInfoCard(),
                  Gap(AppSize.s16.h),
                  _buildSkipTypeSelection(),
                  Gap(AppSize.s16.h),
                  _buildDateSelection(),
                  Gap(AppSize.s16.h),
                  _buildImportantInfoCard(),
                  Gap(AppSize.s24.h),
                  _buildActionButtons(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLimitInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.state.warningSurface,
        border: Border.all(color: ColorManager.state.warningBorder),
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: ColorManager.state.warning,
            size: AppSize.s20,
          ),
          Gap(AppSize.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${Strings.skipLimit.tr()} ${widget.skipDaysUsed}/${widget.skipDaysLimit}",
                  style: getRegularTextStyle(
                    color: ColorManager.state.warningEmphasis,
                    fontSize: FontSizeManager.s14.sp,
                  ),
                ),
                Gap(AppSize.s4.h),
                Text(
                  "${Strings.youHave.tr()} ${widget.remainingSkipDays} ${Strings.skipsRemaining.tr()}",
                  style: getRegularTextStyle(
                    color: ColorManager.state.warningEmphasis,
                    fontSize: FontSizeManager.s14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.background.surface,
        border: Border.all(color: ColorManager.border.defaultColor),
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.skipType.tr(),
            style: getRegularTextStyle(
              color: ColorManager.text.primary,
              fontSize: FontSizeManager.s16.sp,
            ),
          ),
          Gap(AppSize.s16.h),
          Row(
            children: [
              Expanded(
                child: _buildTypeCard(
                  type: SkipTypeSelection.singleDay,
                  title: Strings.singleDay.tr(),
                  subtitle: Strings.skipOneDay.tr(),
                ),
              ),
              Gap(AppSize.s12.w),
              Expanded(
                child: _buildTypeCard(
                  type: SkipTypeSelection.dateRange,
                  title: Strings.dateRange.tr(),
                  subtitle: Strings.skipMultipleDays.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required SkipTypeSelection type,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _skipType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _skipType = type;
        });
      },
      borderRadius: BorderRadius.circular(AppSize.s12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppPadding.p16,
          horizontal: AppPadding.p8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorManager.brand.primaryTint
                  : ColorManager.background.surface,
          border: Border.all(
            color:
                isSelected
                    ? ColorManager.brand.primary
                    : ColorManager.border.defaultColor,
          ),
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: getRegularTextStyle(
                color: ColorManager.text.primary,
                fontSize: FontSizeManager.s14.sp,
              ),
            ),
            Gap(AppSize.s4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: getRegularTextStyle(
                color: ColorManager.text.secondary,
                fontSize: FontSizeManager.s12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.background.surface,
        border: Border.all(color: ColorManager.border.defaultColor),
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_skipType == SkipTypeSelection.singleDay) ...[
            Text(
              Strings.startDate.tr(),
              style: getRegularTextStyle(
                color: ColorManager.text.primary,
                fontSize: FontSizeManager.s16.sp,
              ),
            ),
            Gap(AppSize.s8.h),
            _buildDatePicker(
              date: _startDate,
              onDateChanged: (date) {
                setState(() => _startDate = date);
              },
            ),
          ] else ...[
            Text(
              Strings.startDate.tr(),
              style: getRegularTextStyle(
                color: ColorManager.text.primary,
                fontSize: FontSizeManager.s16.sp,
              ),
            ),
            Gap(AppSize.s8.h),
            _buildDatePicker(
              date: _startDate,
              onDateChanged: (date) {
                setState(() => _startDate = date);
              },
            ),
            Gap(AppSize.s16.h),
            Text(
              Strings.endDate.tr(),
              style: getRegularTextStyle(
                color: ColorManager.text.primary,
                fontSize: FontSizeManager.s16.sp,
              ),
            ),
            Gap(AppSize.s8.h),
            _buildDatePicker(
              date: _endDate,
              onDateChanged: (date) {
                setState(() => _endDate = date);
              },
              firstDate: _startDate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime? date,
    required ValueChanged<DateTime?> onDateChanged,
    DateTime? firstDate,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? firstDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p16,
          vertical: AppPadding.p12,
        ),
        decoration: BoxDecoration(
          color: ColorManager.background.subtle,
          borderRadius: BorderRadius.circular(AppSize.s8),
          border: Border.all(color: ColorManager.border.defaultColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat(
                    'MMMM d, yyyy',
                    context.locale.toString(),
                  ).format(date)
                  : '',
              style: getRegularTextStyle(
                color: ColorManager.text.primary,
                fontSize: FontSizeManager.s16.sp,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: ColorManager.grey6A7282,
              size: AppSize.s20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportantInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.background.app,
        border: Border.all(color: ColorManager.border.defaultColor),
        borderRadius: BorderRadius.circular(AppSize.s12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.importantInformation.tr(),
            style: getRegularTextStyle(
              color: ColorManager.text.primary,
              fontSize: FontSizeManager.s16.sp,
            ),
          ),
          Gap(AppSize.s12.h),
          _buildInfoBullet(Strings.skipInfo1.tr()),
          Gap(AppSize.s8.h),
          _buildInfoBullet(Strings.skipInfo2.tr()),
          Gap(AppSize.s8.h),
          _buildInfoBullet(Strings.skipInfo3.tr()),
        ],
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Text(
      text,
      style: getRegularTextStyle(
        color: ColorManager.text.secondary,
        fontSize: FontSizeManager.s14.sp,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SkipDaysState state) {
    final isLoading = state is SkipDaysLoading;

    bool hasValidSelection = false;
    if (_skipType == SkipTypeSelection.singleDay) {
      hasValidSelection = _startDate != null;
    } else {
      hasValidSelection = _startDate != null && _endDate != null;
    }

    final isEnabled = hasValidSelection && !isLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
              side: BorderSide(color: ColorManager.border.defaultColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s12),
              ),
            ),
            child: Text(
              Strings.cancel.tr(),
              style: getRegularTextStyle(
                color: ColorManager.text.primary,
                fontSize: FontSizeManager.s16.sp,
              ),
            ),
          ),
        ),
        Gap(AppSize.s12.w),
        Expanded(
          child: ButtonWidget(
            text: isLoading ? Strings.loading.tr() : Strings.skipDays.tr(),
            height: 52,
            color:
                hasValidSelection
                    ? ColorManager.brand.primary
                    : ColorManager.state.disabledSurface,
            radius: AppSize.s12,
            onTap:
                isEnabled
                    ? () {
                      if (_skipType == SkipTypeSelection.singleDay) {
                        context.read<SkipDaysBloc>().add(
                          SkipSingleDayEvent(
                            widget.subscriptionId,
                            DateFormat('yyyy-MM-dd').format(_startDate!),
                          ),
                        );
                      } else {
                        context.read<SkipDaysBloc>().add(
                          SkipDateRangeEvent(
                            widget.subscriptionId,
                            DateFormat('yyyy-MM-dd').format(_startDate!),
                            DateFormat('yyyy-MM-dd').format(_endDate!),
                          ),
                        );
                      }
                    }
                    : null,
          ),
        ),
      ],
    );
  }
}

import 'package:basic_diet/presentation/resources/color_manager.dart';
import 'package:basic_diet/presentation/resources/theme_manager.dart';
import 'package:basic_diet/presentation/resources/values_manager.dart';
import 'package:basic_diet/presentation/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  Widget buildHarness(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(AppSize.s392, AppSize.s851),
      child: MaterialApp(
        theme: getApplicationTheme(),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('ButtonWidget uses brand primary styling when enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(ButtonWidget(radius: 16, text: 'Continue', onTap: () {})),
    );

    final animatedContainer = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(ButtonWidget),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = animatedContainer.decoration! as BoxDecoration;

    expect(decoration.color, ColorManager.brandPrimary);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('ButtonWidget uses disabled surface styling when disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const ButtonWidget(radius: 16, text: 'Continue', onTap: null),
      ),
    );

    final animatedContainer = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(ButtonWidget),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = animatedContainer.decoration! as BoxDecoration;

    expect(decoration.color, ColorManager.stateDisabledSurface);
  });
}

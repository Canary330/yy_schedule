import 'package:flutter_test/flutter_test.dart';
import 'package:yy_schedule/app/app.dart';
import 'package:yy_schedule/core/app_core.dart';

void main() {
  testWidgets('shows core tabs and actions', (tester) async {
    await tester.pumpWidget(
      ScheduleApp(
        initialSnapshot: AppSnapshot(
          courses: const [],
          todos: const [],
          settings: AppSettings.initial(),
        ),
      ),
    );

    expect(find.text('丫丫课程表'), findsOneWidget);
    expect(find.text('一键导课'), findsOneWidget);
    expect(find.text('手动添课'), findsOneWidget);
    expect(find.text('课表'), findsOneWidget);
    expect(find.text('待办'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/userManager.dart'; // Pfad anpassen

void main() {
  group('UserManager', () {
    testWidgets('Should login a User and return true', (WidgetTester tester) async {
      late BuildContext context;
      await tester.pumpWidget(
      Builder(
        builder: (ctx) {
        context = ctx;
        return Container();
        },
      ),
      );

      expect(await UserManager.Login(context, 'admin', 'admin'), true);
    });

  testWidgets('Should login a non existing User and return false', (WidgetTester tester) async {
      late BuildContext context;
      await tester.pumpWidget(
      Builder(
        builder: (ctx) {
        context = ctx;
        return Container();
        },
      ),
      );

      expect(await UserManager.Login(context, '', ''), false);
    });
  });
}
import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:intl/intl.dart';

mixin DateAndTimePicker {
  Future<DateTime?> customDatePicker({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    DateTime? finalDate;
    finalDate = await showDatePicker(
      initialDate: DateTime.now(),
      context: RouteManager.navigatorKey.currentState!.context,
      firstDate: startDate ?? DateTime(1940),
      lastDate: endDate ?? DateTime.now(),
    );
    return finalDate;
  }

  String userDateFormat(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String companyDateFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<String?> customTimePicker({String? initialDate}) async {
    String? formattedTime;
    await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: RouteManager.navigatorKey.currentState!.context,
    ).then((time) async {
      if (time != null) {
        formattedTime = DateFormat(
          'jm',
        ).format(DateTime(0, 0, 0, time.hour, time.minute));
      }
    });
    return formattedTime ?? '';
  }
}

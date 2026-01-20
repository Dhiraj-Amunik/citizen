import 'package:flutter/material.dart';
import 'package:inldsevak/core/routes/routes.dart';
import 'package:inldsevak/core/utils/app_palettes.dart';
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
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    return finalDate;
  }

  String userDateFormat(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String companyDateFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<String?> customTimePicker() async {
    String? formattedTime;
    await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: RouteManager.navigatorKey.currentState!.context,
    ).then((time) async {
      if (time != null) {
        formattedTime = DateFormat(
          'jm',
        ).format(DateTime(0, 0, 0, time.hour + 00, time.minute));
      }
    });
    return formattedTime ?? '';
  }

  Future<String?> custom24HrsTimePicker() async {
    String? formattedTime;
    final context = RouteManager.navigatorKey.currentState!.context;
    await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppPalettes.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    ).then((time) async {
      if (time != null) {
        formattedTime = DateFormat(
          'HH:mm',
        ).format(DateTime(0, 0, 0, time.hour + 00, time.minute));
      }
    });
    return formattedTime ?? '';
  }
}

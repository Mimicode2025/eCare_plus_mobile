import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

ThemeData _pickerTheme(BuildContext context, {bool compactCalendar = false}) {
  final inherited = Theme.of(context);
  final theme = compactCalendar
      ? ThemeData(
          useMaterial3: false,
          colorScheme: inherited.colorScheme,
          textTheme: inherited.textTheme,
        )
      : inherited;

  return theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.textDark,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      dayStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      weekdayStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      dayShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? AppColors.primary : null;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return AppColors.textHint;
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.textDark;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.primary,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.transparent,
      ),
      todayBorder: const BorderSide(color: AppColors.primary),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      hourMinuteShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hourMinuteColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.scaffoldBackground,
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textDark,
      ),
      hourMinuteTextStyle: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      dialBackgroundColor: AppColors.scaffoldBackground,
      dialHandColor: AppColors.primary,
      dayPeriodColor: AppColors.primary,
      dayPeriodTextColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryLighter,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      helpTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

Future<DateTime?> showCareDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => Theme(
      data: _pickerTheme(context, compactCalendar: true),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(
            context,
          ).clamp(maxScaleFactor: 1.2),
        ),
        child: _CareDatePicker(
          initialDate: DateUtils.dateOnly(initialDate),
          firstDate: DateUtils.dateOnly(firstDate),
          lastDate: DateUtils.dateOnly(lastDate),
          helpText: helpText,
        ),
      ),
    ),
  );
}

Future<TimeOfDay?> showCareTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.input,
    builder: (context, child) => Theme(
      data: _pickerTheme(context),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
          textScaler: MediaQuery.textScalerOf(
            context,
          ).clamp(maxScaleFactor: 1.2),
        ),
        child: child!,
      ),
    ),
  );
}

class _CareDatePicker extends StatefulWidget {
  const _CareDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.helpText,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helpText;

  @override
  State<_CareDatePicker> createState() => _CareDatePickerState();
}

class _CareDatePickerState extends State<_CareDatePicker> {
  late DateTime _selected = widget.initialDate;
  final _inputKey = GlobalKey<FormState>();
  bool _typing = false;

  bool _saveInput() {
    if (!_typing) return true;
    if (!_inputKey.currentState!.validate()) return false;
    _inputKey.currentState!.save();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final labels = MaterialLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 328,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.helpText != null || _typing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      widget.helpText ?? labels.datePickerHelpText,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              if (_typing)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _inputKey,
                    child: InputDatePickerFormField(
                      initialDate: _selected,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      autofocus: true,
                      onDateSaved: (date) => _selected = date,
                      onDateSubmitted: (date) => Navigator.pop(context, date),
                    ),
                  ),
                )
              else
                CalendarDatePicker(
                  key: ValueKey(_typing),
                  initialDate: _selected,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (date) => setState(() => _selected = date),
                ),
              Row(
                children: [
                  IconButton(
                    tooltip: _typing
                        ? labels.calendarModeButtonLabel
                        : labels.inputDateModeButtonLabel,
                    icon: Icon(
                      _typing
                          ? Icons.calendar_month_outlined
                          : Icons.edit_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_saveInput()) setState(() => _typing = !_typing);
                    },
                  ),
                  Expanded(
                    child: OverflowBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(labels.cancelButtonLabel),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_saveInput()) Navigator.pop(context, _selected);
                          },
                          child: Text(labels.okButtonLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

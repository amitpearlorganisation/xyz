
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../schedule/cubit/scheduleflow_cubit.dart';

class DateTimePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final String ? flowId;
  final String ? flowname;

  DateTimePickerDialog({required this.initialDate, required this.initialTime, required this.flowId, required this.flowname});

  @override
  _DateTimePickerDialogState createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void alram({ DateTime? dateTime}) async {
    var newdate = dateTime?.toUtc();
    var localDateTime = newdate?.toLocal();
  }


  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Select Date and Time'),
          SizedBox(width: 10,),
          Icon(Icons.watch_later_outlined)
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    width: 1.5,
                    color: Colors.grey.shade200
                )
            ),
            child: ListTile(
              title: Text('Date', style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8))),
              subtitle: Text(
                '${selectedDate?.year}-${selectedDate?.month}-${selectedDate
                    ?.day}', style: TextStyle(color: Colors.green),),

              onTap: _pickDate,
            ),
          ),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    width: 1.5,
                    color: Colors.grey.shade200
                )
            ),
            child: ListTile(
              title: Text('Time', style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8))),
              subtitle: Text('${selectedTime?.hour}:${selectedTime?.minute}',
                  style: TextStyle(color: Colors.green)),
              onTap: _pickTime,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (selectedDate != null && selectedTime != null) {
              DateTime scheduledDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              if (scheduledDateTime.isBefore(DateTime.now())) {
                // If selected time is in the past
                EasyLoading.showError("Past time can't be set");
              } else {
                // Notify user that past time can't be set
                context.read<ScheduleflowCubit>().addDateTime(
                  flowName: widget.flowname.toString(),
                  scheduledDateTime: scheduledDateTime,
                  flowId: widget.flowId.toString(),
                );
                Navigator.of(context).pop(true);
              }
            } else {
              // Handle case where date or time is not selected
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {

                return Colors.red;
              },
            ),
          ),
          child: Text("Schedule flow"),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime.now(), // Set minimum date to today
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime!,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      // Check if picked time is in the past
      DateTime currentTime = DateTime.now();
      DateTime pickedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (pickedDateTime.isAfter(currentTime) ||
          pickedDateTime.isAtSameMomentAs(currentTime)) {
        setState(() {
          selectedTime = pickedTime;
        });
      } else {
        // Notify user that they cannot select past time
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(

            content: Text("Cannot select past time"),
          ),
        );
      }
    }
  }
}

import 'package:class_calender/models/class_model.dart';
import 'package:class_calender/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void navigateToAddClassScreen(
    {required BuildContext context,
    required Function getClasses,
    required DateTime selectedDate}) async {
  String? subjectName;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String startTimeString = "";
  String endTimeString = "";
  DatabaseHelper dbHelper = DatabaseHelper();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Add New Class'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                  onChanged: (value) {
                    subjectName = value;
                  },
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        startTime = pickedTime;
                        startTimeString = DateFormat.jm().format(DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            startTime!.hour,
                            startTime!.minute));
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Time'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(startTime != null
                            ? startTimeString
                            : 'Select Start Time'),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        endTime = pickedTime;
                        endTimeString = DateFormat.jm().format(DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            endTime!.hour,
                            endTime!.minute));
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'End Time'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(endTime != null
                            ? endTimeString
                            : 'Select End Time'),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (subjectName != null &&
                      startTime != null &&
                      endTime != null) {
                    dbHelper.insertClass(
                        ClassModel(
                            subjectName: subjectName!,
                            startTime: startTimeString,
                            endTime: endTimeString),
                        selectedDate);
                    getClasses(date: selectedDate);

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

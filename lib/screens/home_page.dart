import 'package:class_calender/models/class_model.dart';
import 'package:class_calender/screens/add_class_dialog.dart';
import 'package:class_calender/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  DatabaseHelper dbHelper = DatabaseHelper();
  List<ClassModel> allClasses = [];
  List<DateTime> allDates = [];

  void getClasses({required DateTime date}) async {
    allDates = await dbHelper.getAllDistinctDates();
    allClasses = await dbHelper.getClassesByDate(date);
    setState(() {});
  }

  @override
  void initState() {
    getClasses(date: DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Time Table",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: SfCalendar(
                showTodayButton: true,
                cellBorderColor: Colors.blue,
                todayHighlightColor: Colors.green,
                view: CalendarView.month,
                onSelectionChanged: (calendarSelectionDetails) {
                  selectedDate = calendarSelectionDetails.date!;
                  getClasses(date: selectedDate);
                },
                dataSource: _getCalendarDataSource(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate.day == DateTime.now().day
                        ? "Today's Classes"
                        : "${DateFormat.yMMMd().format(selectedDate)} Classes",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      navigateToAddClassScreen(
                          context: context,
                          getClasses: getClasses,
                          selectedDate: selectedDate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Text(
                        "Add Class",
                        style: TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            if (allClasses.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: const Text(
                      "No Class Added",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ...allClasses.map((e) => Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 14),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(colors: [
                        Colors.blue,
                        Color.fromARGB(255, 61, 177, 245)
                      ])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          e.subjectName,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text("${e.startTime} - ${e.endTime}")
                    ],
                  ),
                )),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  _AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> appointments = <Appointment>[];
    for (int i = 0; i < allDates.length; i++) {
      appointments.add(Appointment(
        startTime: allDates[i].add(const Duration(hours: 2)),
        endTime: allDates[i].add(const Duration(hours: 3)),
        subject: 'class',
        color: Colors.green,
      ));
    }

    return _AppointmentDataSource(appointments);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

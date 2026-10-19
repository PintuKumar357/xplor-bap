import 'package:flutter/material.dart';
import 'package:xplor/features/appointmet/presentation/pages/doctor/doctor.dart';
import 'package:xplor/utils/common_top_header.dart';

class AppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentScreen({super.key, required this.doctor});
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  String consultationType = '';
  String selectedTimeSlot = '';

  List<String> _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
    List<String> timeSlots = [];
    TimeOfDay currentTime = startTime;

    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour &&
            currentTime.minute < endTime.minute)) {
      timeSlots.add(currentTime.format(context));
      int newMinute = currentTime.minute + 15;
      int newHour = currentTime.hour;

      if (newMinute >= 60) {
        newMinute -= 60;
        newHour += 1;
      }

      currentTime = TimeOfDay(hour: newHour, minute: newMinute);
    }
    return timeSlots;
  }

  @override
  Widget build(BuildContext context) {
    TimeOfDay now = TimeOfDay.now();
    TimeOfDay morningStart = TimeOfDay(hour: 7, minute: 0);
    TimeOfDay morningEnd = TimeOfDay(hour: 11, minute: 0);
    TimeOfDay eveningStart = TimeOfDay(hour: 16, minute: 0);
    TimeOfDay eveningEnd = TimeOfDay(hour: 21, minute: 0);

    List<String> morningSlots = [];
    List<String> eveningSlots = [];

    if (selectedDate.day == DateTime.now().day) {
      if (now.hour < morningEnd.hour ||
          (now.hour == morningEnd.hour && now.minute < morningEnd.minute)) {
        morningSlots = _generateTimeSlots(
            now.hour >= morningStart.hour ? now : morningStart, morningEnd);
      }

      if (now.hour < eveningEnd.hour ||
          (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
        eveningSlots = _generateTimeSlots(
            now.hour >= eveningStart.hour ? now : eveningStart, eveningEnd);
      }
    } else {
      morningSlots = _generateTimeSlots(morningStart, morningEnd);
      eveningSlots = _generateTimeSlots(eveningStart, eveningEnd);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: CommonTopHeader(
          title: 'Book Appointment  ',
          isTitleOnly: false,
          dividerColor: Colors.grey,
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Adjust height as needed  child: CommonTopHeader(    title: 'Health Details',    isTitleOnly: false,    dividerColor: Colors.grey,
      // Use appropriate color    onBackButtonPressed: () => Navigator.of(context).pop(),  ),),
      /*AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Book Appointment with ${widget.doctor.name}'),
      )*/
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Details
            Center(
              child: Column(),
            ),
            SizedBox(height: 16.0),
            // Date Selector
            ListTile(
              title: Text("Select Date"),
              subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16.0),
            // Time Slot Selector
            Text("Select Morning Slot"),
            morningSlots.isNotEmpty
                ? Wrap(
                    spacing: 8.0,
                    children: morningSlots.map((String time) {
                      return ChoiceChip(
                        label: Text(time),
                        selected: selectedTimeSlot == time,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedTimeSlot = time;
                          });
                        },
                      );
                    }).toList(),
                  )
                : Text("No morning slots available"),
            SizedBox(height: 16.0),
            Text("Select Evening Slot"),
            eveningSlots.isNotEmpty
                ? Wrap(
                    spacing: 8.0,
                    children: eveningSlots.map((String time) {
                      return ChoiceChip(
                        label: Text(time),
                        selected: selectedTimeSlot == time,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedTimeSlot = time;
                          });
                        },
                      );
                    }).toList(),
                  )
                : Text("No evening slots available"),
            SizedBox(height: 16.0),
            // Consultation Type
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        consultationType = 'Video';
                      });
                    },
                    child: Text('Video Consultation'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: consultationType == 'Video'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        consultationType = 'Audio';
                      });
                    },
                    child: Text('Audio Consultation'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: consultationType == 'Audio'
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Next Button
            ElevatedButton(
              onPressed: () {
                // Handle next button press
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Appointment Booked'),
                      content: Text(
                          'Appointment booked with ${widget.doctor.name} on ${selectedDate.toLocal()} at $selectedTimeSlot for $consultationType consultation.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Book Appointment'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}

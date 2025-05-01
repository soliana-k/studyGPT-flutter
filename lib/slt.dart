// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class ScheduleCard extends StatefulWidget {
//   final VoidCallback onDismiss;
//
//   ScheduleCard({required this.onDismiss});
//
//
//   @override
//   _ScheduleCardState createState() => _ScheduleCardState();
// }
//
//
// class _ScheduleCardState extends State<ScheduleCard> {
//   TimeOfDay? selectedTime;
//   List<String> selectedDays = [];
//
//   final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//
//   void _pickTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime ?? TimeOfDay.now(),
//     );
//
//     if (picked != null) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }
//
//   void _toggleDay(String day) {
//     setState(() {
//       if (selectedDays.contains(day)) {
//         selectedDays.remove(day);
//       } else {
//         selectedDays.add(day);
//       }
//     });
//   }
//
//   void _saveSchedule() {
//     if (selectedDays.isEmpty || selectedTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select at least one day and time')),
//       );
//       return;
//     }
//
//     // 🔥 Save to Firestore or local storage here
//
//     print('Schedule saved: $selectedDays at ${selectedTime!.format(context)}');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Schedule saved!')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Color.fromRGBO(248, 249, 250, 1),
//       child: Padding(
//         padding: EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.calendar_month_outlined, color: Colors.grey),
//                 SizedBox(width: 10),
//                 Text("Schedule learning time", style: TextStyle(fontWeight: FontWeight.bold)),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text("Pick the days and time you'd like to learn.", style: TextStyle(color: Colors.black54)),
//             SizedBox(height: 10),
//
//             // Day Picker
//             Wrap(
//               spacing: 6,
//               children: days.map((day) {
//                 final isSelected = selectedDays.contains(day);
//                 return ChoiceChip(
//                   label: Text(day),
//                   selected: isSelected,
//                   onSelected: (_) => _toggleDay(day),
//                   selectedColor: Colors.blue.shade100,
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 10),
//
//             // Time Picker
//             Row(
//               children: [
//                 Text("Time: "),
//                 TextButton.icon(
//                   onPressed: _pickTime,
//                   icon: Icon(Icons.access_time),
//                   label: Text(selectedTime != null ? selectedTime!.format(context) : "Pick time"),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 ElevatedButton(onPressed: _saveSchedule, child: Text("Schedule")),
//                 SizedBox(width: 10),
//                 TextButton(
//                   onPressed: widget.onDismiss,
//                   child: Text("Dismiss"),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class ScheduleCard extends StatefulWidget {
  final VoidCallback onDismiss;

  ScheduleCard({required this.onDismiss});

  @override
  _ScheduleCardState createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  TimeOfDay? selectedTime;
  List<String> selectedDays = [];

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Map<String, int> weekdayMap = {
    'Mon': DateTime.monday,
    'Tue': DateTime.tuesday,
    'Wed': DateTime.wednesday,
    'Thu': DateTime.thursday,
    'Fri': DateTime.friday,
    'Sat': DateTime.saturday,
    'Sun': DateTime.sunday,
  };

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  void _saveSchedule() async {
    if (selectedDays.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one day and time')),
      );
      return;
    }

    final scheduleData = {
      'days': selectedDays,
      'time': '${selectedTime!.hour}:${selectedTime!.minute}',
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('schedules').add(scheduleData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔥 Error saving to Firestore: $e')),
      );
      return;
    }

    for (var day in selectedDays) {
      try {
        await _scheduleNotification(day, selectedTime!);
      } catch (e) {
        print('⚠️ Failed to schedule notification for $day: $e');

      }
    }


    widget.onDismiss();
  }

  Future<void> _scheduleNotification(String day, TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    final targetWeekday = weekdayMap[day]!;

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != targetWeekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduledDate.hashCode,
      '⏰ Study Reminder',
      'Time to study!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'study_channel',
          'Study Reminders',
          channelDescription: 'Scheduled study notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(248, 249, 250, 1),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: Colors.grey),
                SizedBox(width: 10),
                Text("Schedule learning time",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Text("Pick the days and time you'd like to learn.",
                style: TextStyle(color: Colors.black54)),
            SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: days.map((day) {
                final isSelected = selectedDays.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (_) => _toggleDay(day),
                  selectedColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Time: "),
                TextButton.icon(
                  onPressed: _pickTime,
                  icon: Icon(Icons.access_time),
                  label: Text(selectedTime != null
                      ? selectedTime!.format(context)
                      : "Pick time"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: _saveSchedule, child: Text("Schedule")),
                SizedBox(width: 10),
                TextButton(
                  onPressed: widget.onDismiss,
                  child: Text("Dismiss"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// class ScheduleScreen extends StatefulWidget {
//   @override
//   _ScheduleScreenState createState() => _ScheduleScreenState();
// }
//
// class _ScheduleScreenState extends State<ScheduleScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   Map<DateTime, List<String>> _events = {};
//
//   List<String> _getEventsForDay(DateTime day) {
//     return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
//   }
//
//   void _addEvent(String title) {
//     final eventDay = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
//     if (_events[eventDay] == null) {
//       _events[eventDay] = [title];
//     } else {
//       _events[eventDay]!.add(title);
//     }
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Schedule')),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _focusedDay,
//             calendarFormat: _calendarFormat,
//             selectedDayPredicate: (day) {
//               return isSameDay(_selectedDay, day);
//             },
//             eventLoader: _getEventsForDay,
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//             },
//             onFormatChanged: (format) {
//               setState(() {
//                 _calendarFormat = format;
//               });
//             },
//             onPageChanged: (focusedDay) {
//               _focusedDay = focusedDay;
//             },
//           ),
//           const SizedBox(height: 8.0),
//           ElevatedButton(
//             onPressed: () {
//               if (_selectedDay == null) return;
//
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   String newEventTitle = '';
//                   return AlertDialog(
//                     title: Text("Add Event"),
//                     content: TextField(
//                       decoration: InputDecoration(hintText: "Event title"),
//                       onChanged: (value) => newEventTitle = value,
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: Text("Cancel"),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           if (newEventTitle.trim().isNotEmpty) {
//                             _addEvent(newEventTitle.trim());
//                             Navigator.pop(context);
//                           }
//                         },
//                         child: Text("Add"),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: Text("Add Event"),
//           ),
//           const SizedBox(height: 8.0),
//           Expanded(
//             child: _selectedDay == null
//                 ? Center(child: Text("Select a day to view events"))
//                 : ListView(
//               children: _getEventsForDay(_selectedDay!).map((event) {
//                 return ListTile(
//                   title: Text(event),
//                   leading: Icon(Icons.event),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, String>>> _events = {};

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _addEvent(String title, String description) async {
    if (_selectedDay == null) return;

    final eventDay = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

    // Add event data to Firestore
    await FirebaseFirestore.instance.collection('events').add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(eventDay),
      'createdAt': Timestamp.now(),
    });

    setState(() {
      // After adding the event, refresh the events list
      _events[eventDay] = _events[eventDay] ?? [];
      _events[eventDay]!.add({
        'title': title,
        'description': description,
      });
    });
  }

  Future<void> _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    final Map<DateTime, List<Map<String, String>>> fetchedEvents = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final title = data['title'] as String;
      final description = data['description'] as String;

      final eventDate = DateTime.utc(date.year, date.month, date.day);
      if (fetchedEvents[eventDate] == null) {
        fetchedEvents[eventDate] = [{'title': title, 'description': description}];
      } else {
        fetchedEvents[eventDate]!.add({'title': title, 'description': description});
      }
    }

    setState(() {
      _events = fetchedEvents;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents(); // Fetch events on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: Text('Schedule', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.arrow_left, color: Colors.teal.shade700),
              rightChevronIcon: Icon(Icons.arrow_right, color: Colors.teal.shade700),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.teal.shade200,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.teal.shade500),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_selectedDay == null) return;

              showDialog(
                context: context,
                builder: (context) {
                  String newEventTitle = '';
                  String newEventDescription = '';
                  return AlertDialog(
                    title: Text("Add Event"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(hintText: "Event title"),
                          onChanged: (value) => newEventTitle = value,
                        ),
                        TextField(
                          decoration: InputDecoration(hintText: "Event description (optional)"),
                          onChanged: (value) => newEventDescription = value,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          if (newEventTitle.trim().isNotEmpty) {
                            _addEvent(newEventTitle.trim(), newEventDescription.trim());
                            Navigator.pop(context);
                          }
                        },
                        child: Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text("Add Event"),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text("Select a day to view events"))
                : ListView(
              children: _getEventsForDay(_selectedDay!).map((event) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // White background for the card
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event, color: Colors.teal.shade400),
                                SizedBox(width: 12),
                                Expanded(child: Text(event['title']!, style: TextStyle(fontSize: 16))),
                              ],
                            ),
                            if (event['description'] != null && event['description']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  event['description']!,
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

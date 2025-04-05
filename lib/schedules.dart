import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _addEvent(String title) {
    final eventDay = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    if (_events[eventDay] == null) {
      _events[eventDay] = [title];
    } else {
      _events[eventDay]!.add(title);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule')),
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
          ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              if (_selectedDay == null) return;

              showDialog(
                context: context,
                builder: (context) {
                  String newEventTitle = '';
                  return AlertDialog(
                    title: Text("Add Event"),
                    content: TextField(
                      decoration: InputDecoration(hintText: "Event title"),
                      onChanged: (value) => newEventTitle = value,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          if (newEventTitle.trim().isNotEmpty) {
                            _addEvent(newEventTitle.trim());
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
                return ListTile(
                  title: Text(event),
                  leading: Icon(Icons.event),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
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
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Map<DateTime, List<String>> _events = {};
//   List<String> _selectedEvents = [];
//   User? _user;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = _getDateOnly(_focusedDay);
//     _loadEvents();
//     _checkAuthentication();
//   }
//
//   DateTime _getDateOnly(DateTime date) {
//     return DateTime(date.year, date.month, date.day);
//   }
//
//   void _checkAuthentication() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         _user = user;
//       });
//     } else {
//       _signInWithGoogle();
//     }
//   }
//
//   Future<void> _signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
//
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//       setState(() {
//         _user = userCredential.user;
//       });
//     } catch (e) {
//       print('Error signing in: $e');
//     }
//   }
//
//   void _loadEvents() async {
//     final snapshot = await _firestore.collection('schedules').get();
//
//     Map<DateTime, List<String>> loadedEvents = {};
//
//     for (var doc in snapshot.docs) {
//       final date = _getDateOnly(DateTime.parse(doc['date']));
//       final title = doc['title'];
//
//       if (!loadedEvents.containsKey(date)) {
//         loadedEvents[date] = [];
//       }
//       loadedEvents[date]!.add(title);
//     }
//
//     setState(() {
//       _events = loadedEvents;
//       _selectedEvents = _events[_selectedDay] ?? [];
//     });
//   }
//
//   void _addEvent(String title) async {
//     final eventDate = _getDateOnly(_selectedDay!);
//
//     // Add event to Firestore
//     await _firestore.collection('schedules').add({
//       'date': eventDate.toIso8601String(),
//       'title': title,
//       'userId': _user?.uid, // Store the user ID for tracking
//     });
//
//     // Add the event to the local list immediately (this triggers a UI update)
//     setState(() {
//       if (_events[eventDate] != null) {
//         _events[eventDate]!.add(title);
//       } else {
//         _events[eventDate] = [title];
//       }
//       _selectedEvents = _events[eventDate]!;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Schedule'),
//         actions: [
//           if (_user != null)
//             IconButton(
//               icon: Icon(Icons.exit_to_app),
//               onPressed: () async {
//                 await _auth.signOut();
//                 setState(() {
//                   _user = null;
//                 });
//               },
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (_user == null)
//             Center(child: CircularProgressIndicator()) // Show loading until signed in
//           else ...[
//             TableCalendar(
//               firstDay: DateTime.utc(2020, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               focusedDay: _focusedDay,
//               calendarFormat: _calendarFormat,
//               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//               onDaySelected: (selectedDay, focusedDay) {
//                 final dateOnly = _getDateOnly(selectedDay);
//                 setState(() {
//                   _selectedDay = dateOnly;
//                   _focusedDay = focusedDay;
//                   _selectedEvents = _events[dateOnly] ?? [];
//                 });
//               },
//               onFormatChanged: (format) {
//                 setState(() => _calendarFormat = format);
//               },
//             ),
//             const SizedBox(height: 8.0),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _selectedEvents.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     leading: Icon(Icons.event),
//                     title: Text(_selectedEvents[index]),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           String newEvent = '';
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: Text('Add Event'),
//               content: TextField(
//                 onChanged: (value) => newEvent = value,
//                 decoration: InputDecoration(hintText: 'Event title'),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (newEvent.isNotEmpty) {
//                       _addEvent(newEvent);
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Text('Add'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

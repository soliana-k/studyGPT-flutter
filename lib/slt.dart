import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void _saveSchedule() {
    if (selectedDays.isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one day and time')),
      );
      return;
    }

    // 🔥 Save to Firestore or local storage here

    print('Schedule saved: $selectedDays at ${selectedTime!.format(context)}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule saved!')),
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
                Text("Schedule learning time", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Text("Pick the days and time you'd like to learn.", style: TextStyle(color: Colors.black54)),
            SizedBox(height: 10),

            // Day Picker
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

            // Time Picker
            Row(
              children: [
                Text("Time: "),
                TextButton.icon(
                  onPressed: _pickTime,
                  icon: Icon(Icons.access_time),
                  label: Text(selectedTime != null ? selectedTime!.format(context) : "Pick time"),
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

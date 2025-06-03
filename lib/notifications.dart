import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, String>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('username');

    if (userEmail == null) {
      setState(() => _loading = false);
      return;
    }

    List<Map<String, String>> result = [];

    try {
      // 📅 Firestore schedules
      final scheduleSnapshot = await FirebaseFirestore.instance
          .collection('user_schedules')
          .doc(userEmail)
          .collection('schedules')
          .get();

      for (var doc in scheduleSnapshot.docs) {
        final data = doc.data();
        final time = data['time'];
        final days = List<String>.from(data['days']);

        result.add({
          'title': '📚 Study Reminder',
          'message': 'Scheduled at $time on ${days.join(", ")}',
        });
      }

      // 🗓 Events (next 7 days)
      final now = DateTime.now();
      final upcomingLimit = now.add(Duration(days: 7));

      final eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(userEmail)
          .collection('user_events')
          .get();

      for (var doc in eventSnapshot.docs) {
        final data = doc.data();
        final title = data['title'] ?? 'No Title';
        final desc = data['description'] ?? 'No Description';
        final dateField = data['date'];

        if (dateField is Timestamp) {
          final eventTime = dateField.toDate();

          if (eventTime.isAfter(now) && eventTime.isBefore(upcomingLimit)) {
            result.add({
              'title': '📅 Upcoming Event: $title',
              'message':
              '🕒 ${DateFormat.yMMMd().add_jm().format(eventTime)} — $desc',
            });
          }
        }
      }

      // 🌐 Announcements from API
      final response = await http.get(Uri.parse(
          'http://56.228.80.139/api/feedback/announcements/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        for (var announcement in data) {
          if (announcement['is_active'] == true) {
            final title = announcement['title'] ?? 'Announcement';
            final content = announcement['content'] ?? '';
            final createdAt = announcement['created_at'];

            result.add({
              'title': '📢 $title',
              'message': '$content\n🗓️ ${DateFormat.yMMMd().add_jm().format(DateTime.parse(createdAt))}',
            });
          }
        }
      } else {
        print("⚠️ Failed to load announcements (${response.statusCode})");
      }

      // ✨ Daily Tip
      result.add({
        'title': '✨ Tip of the Day',
        'message': 'Set small, achievable tasks to boost productivity!',
      });

      setState(() {
        _notifications = result;
        _loading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _loading = false);
    }
  }


  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  Widget _buildNotificationCard(Map<String, String> notif) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Icon(Icons.notifications_active, color: Colors.purple.shade700),
        ),
        title: Text(
          notif['title'] ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          notif['message'] ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Notifications'),
        elevation: 0,
        actions: _notifications.isNotEmpty
            ? [
          IconButton(
            icon: Icon(Icons.clear_all),
            tooltip: "Clear All",
            onPressed: _clearNotifications,
          )
        ]
            : null,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
        child: Text(
          "No notifications 🎉",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) =>
            _buildNotificationCard(_notifications[index]),
      ),
    );
  }
}

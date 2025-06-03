import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studygpt1/challenges.dart';
import 'package:studygpt1/chatbot.dart';
import 'package:studygpt1/schedules.dart';
import 'package:studygpt1/todo.dart';
import 'package:studygpt1/quiz.dart';
import 'package:studygpt1/setting_screen.dart';
import 'package:studygpt1/analytics_page.dart';
import 'login_screen.dart';
import 'slt.dart';
import 'home.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('loggedIn', false);
  runApp(StudyGPTApp());
}

class StudyGPTApp extends StatelessWidget {
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return LoginScreen();
          }
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? StudyGPTHome() : LoginScreen();
        },
      ),
    );
  }
}

class StudyGPTHome extends StatefulWidget {
  @override
  _StudyGPTHomeState createState() => _StudyGPTHomeState();
}

class _StudyGPTHomeState extends State<StudyGPTHome> {
  bool showScheduleCard = true;
  String studyTip = "Loading...";
  bool isLoading = true;
  String studyTipTitle = "Loading...";
  String studyTipDescription = "";
  double pdfReadingProgress = 0.0;
  String username = '';

  final CollectionReference studyTipsCollection =
  FirebaseFirestore.instance.collection('study_tips');

  Future<bool> hasSchedule() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking schedule: $e");
      return false;
    }
  }

  Future<void> _fetchStudyTips() async {
    try {
      QuerySnapshot snapshot = await studyTipsCollection.limit(10).get();
      if (snapshot.docs.isNotEmpty) {
        final randomTip = (snapshot.docs.toList()..shuffle()).first;
        setState(() {
          studyTipTitle = randomTip['title'] ?? "No title";
          studyTipDescription = randomTip['content'] ?? "No description.";
        });
      } else {
        setState(() {
          studyTipTitle = "No study tips found.";
          studyTipDescription = "";
        });
      }
    } catch (e) {
      setState(() {
        studyTipTitle = "Failed to fetch tip.";
        studyTipDescription = "Something went wrong. Try again later.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      studyTip = "Refreshing tip...";
      isLoading = true;
    });
    await _fetchStudyTips();
  }
  void loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('username');
    if (email != null) {
      final name = email.split('@')[0];
      setState(() {
        username = name[0].toUpperCase() + name.substring(1); // Capitalize
      });
    }
  }


  Future<void> _loadReadingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pdfReadingProgress = prefs.getDouble('reading_progress') ?? 0.0;
    });
  }

  Future<void> _checkForSchedule() async {
    bool scheduleExists = await hasSchedule();
    setState(() {
      showScheduleCard = !scheduleExists;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStudyTips();
    _loadReadingProgress();
    _checkForSchedule();
    loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
              color: Colors.black);
        }),
        title: Text('StudyGPT',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon:Icon(Icons.notification_add), color: Colors.black,
            onPressed: () {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => NotificationsPage()));
  },
          ),
          SizedBox(width: 10),
          Icon(Icons.account_circle, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal.shade600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Menu',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('StudyGPT App',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.teal.shade700),
              title: Text('Home', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => StudyGPTHome()));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.teal.shade700),
              title: Text('Chat', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.teal.shade700),
              title: Text('PDF Reader', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PDFReaderPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.checklist, color: Colors.teal.shade700),
              title: Text('To-Do List', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TodoApp()));
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.teal.shade700),
              title: Text('Schedules', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ScheduleScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.quiz, color: Colors.teal.shade700),
              title: Text('Quiz', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Quiz()));
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics, color: Colors.teal.shade700), // Analytics added above Settings
              title: Text('Analytics', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AnalyticsPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.teal.shade700),
              title: Text('Settings', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.grey),
              title: Text('Logout', style: TextStyle(color: Colors.grey)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('loggedIn', false);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<bool>(
          future: hasSchedule(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final scheduleExists = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome, $username!',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    if (showScheduleCard)
                      ScheduleCard(
                        onDismiss: () {
                          setState(() {
                            showScheduleCard = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Schedule dismissed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  showScheduleCard = true;
                                });
                              },
                            ),
                          ));
                        },
                      ),
                    SizedBox(height: 20),
                    Text("Let's start Learning!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    _buildLearningCards(),
                    SizedBox(height: 20),
                    Text("Academic Planners",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    _buildPlannerCards(),
                    SizedBox(height: 20),
                    _buildTipOfTheDay(),
                    SizedBox(height: 20),
                    Text("Daily Challenges 🏆",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TriviaScreen(),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildLearningCards() {
    List<Map<String, dynamic>> subjects = [
      {
        "title": "Mathematics",
        "icon": 'assets/icons/mathematics.svg',
        "color": Colors.blue
      },
      {
        "title": "Chemistry",
        "icon": 'assets/icons/chemistrysvg.svg',
        "color": Colors.green
      },
      {
        "title": "Physics",
        "icon": 'assets/icons/physics.svg',
        "color": Colors.red
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: subjects.map((subject) {
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PDFReaderPage()),
              );

              if (result == true) {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  pdfReadingProgress =
                      prefs.getDouble('reading_progress') ?? 0.0;
                });
              }
            },
            child: _buildLearningCard(
              subject["title"],
              pdfReadingProgress > 0
                  ? "${pdfReadingProgress.round()}% Completed"
                  : "Loading...",
              subject["icon"],
              (pdfReadingProgress / 100).clamp(0.0, 1.0),
              subject["color"],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLearningCard(
      String title, String progress, String icon, double percent, Color col) {
    return Container(
      width: 150,
      height: 160,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 5.0,
                percent: percent,
                center: SvgPicture.asset(icon, width: 40, height: 40),
                progressColor: col,
              ),
              SizedBox(height: 5),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(progress, style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlannerCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlannerCard('assets/icons/todo.svg', 'To-Do List'),
          SizedBox(width: 10),
          _buildPlannerCard('assets/icons/schedule.svg', 'Schedule'),
        ],
      ),
    );
  }

  Widget _buildPlannerCard(String iconPath, String title) {
    return GestureDetector(
      onTap: () {
        if (title == 'To-Do List') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TodoApp()));
        } else if (title == 'Schedule') {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ScheduleScreen()));
        }
      },
      child: Container(
        width: 150,
        height: 160,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(iconPath, width: 60, height: 60),
                SizedBox(height: 16),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipOfTheDay() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.indigo[50],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🧠 Study Tip of the Day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.indigo),
                  onPressed: _refresh,
                ),
              ],
            ),
            SizedBox(height: 10),
            isLoading
                ? Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text(
                  "Fetching tip...",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studyTipTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  studyTipDescription,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
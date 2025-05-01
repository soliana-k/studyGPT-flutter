import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studygpt1/challenges.dart';
import 'package:studygpt1/chatbot.dart';
import 'package:studygpt1/schedules.dart';
import 'package:studygpt1/todo.dart';
import 'slt.dart';
import 'home.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(StudyGPTApp());
}

class StudyGPTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StudyGPTHome(),
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
        final randomTip = (snapshot.docs.toList()
          ..shuffle()).first;
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
            style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Icon(Icons.notification_add, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.account_circle, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal.shade600),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
              },
            ),
            ListTile(
              title: Text('PDF'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PDFReaderPage()));
              },
            ),
            ListTile(
              title: Text('To-Do List'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TodoApp()));
              },
            ),

            ListTile(
              title: Text('Schedules'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ScheduleScreen()));
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
    Text('Welcome, Kal',
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 10),
    _buildLearningCards(),
    SizedBox(height: 20),
    Text("Academic Planners",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 10),
    _buildPlannerCards(),
    SizedBox(height: 20),
    _buildTipOfTheDay(),
    SizedBox(height: 20),
    Text("Daily Challenges 🏆",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 10),
    TriviaScreen(),
    ],
    ),
    ),
    );
    }
    ),
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
                  pdfReadingProgress = prefs.getDouble('reading_progress') ?? 0.0;
                });
              }
            },
            child: _buildLearningCard(
              subject["title"],
              pdfReadingProgress > 0
                  ? "${pdfReadingProgress.round()}% Completed"
                  : "Loading...",
              // Updated dynamically
              subject["icon"],
              (pdfReadingProgress / 100).clamp(0.0, 1.0), // Updated dynamically
              subject["color"],
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildLearningCard(String title, String progress, String icon,
      double percent, Color col) {
    return Container(
      width: 150,
      height: 160,
      child: Card(
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
    );
  }

  Widget _buildPlannerCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPlannerCard('assets/icons/todo.svg', 'To-Do List'),
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleScreen()));
        }
      },
      child: Container(
        width: 150,
        height: 160,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconPath, width: 60, height: 60),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
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
            // Header
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

            // Tip Content
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


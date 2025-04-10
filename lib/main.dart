import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:studygpt1/schedules.dart';
import 'package:studygpt1/todo.dart';
import 'home.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'slt.dart';

void main () async {
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: (){ Scaffold.of(context).openDrawer();},
                icon:Icon(Icons.menu), color: Colors.black);
          }
        ),
        title: Text('StudyGPT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        decoration: BoxDecoration(
        color: Colors.blue,
        ),
        child: Text(
          'Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
        ListTile(
          title: Text('Home'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
          },
        ),
            ListTile(
              title: Text('PDF'),
              //leading: SvgPicture.asset('assets/icons/physics.svg', width: 20.0, height: 20.0,),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp())); // Close the drawer
              },
            ),

        ListTile(
          title: Text('To-Do List'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>TodoApp())); // Close the drawer
          },
        ),
        ListTile(
          title: Text('Schedules'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ScheduleScreen())); // Close the drawer
          },
        )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Kal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (showScheduleCard)
              ScheduleCard(
                onDismiss: () {
                  setState(() {
                    showScheduleCard = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Schedule dismissed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          setState(() {
                            showScheduleCard = true;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 20),
            Text("Let's start Learning!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildLearningCards(),
            SizedBox(height: 20),
            Text("Academic Plannerss", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildPlannerCards(),
            SizedBox(height: 20),
            _buildTipOfTheDay(),
            SizedBox(height: 20),
            Text("Daily Challenges 🏆", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildDailyChallenges(),
          ],
        ),
      ),
    );
  }
  Widget _buildDailyChallenges() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildChallengeCard("Maths", "Solve for X:\n2x + 3 = 11"),
          _buildChallengeCard("Physics", "What is the formula for Kinetic Energy?"),
        ],
      ),
    );
  }
  Widget _buildChallengeCard(String subject, String question) {
    return Container(
      width: 250,
      child: Card(
        color: subject == "Maths" ? Colors.blue : Colors.red,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(question, style: TextStyle(color: Colors.white)),
              TextButton(onPressed: () {}, child: Text("Show Answer", style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}


Widget _buildScheduleCard() {
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
          SizedBox(height: 5),
          Text("Lorem ipsum dolor sit amet consectetuer.", style: TextStyle(color: Colors.black54)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(onPressed: () {}, child: Text("Schedule")),
              SizedBox(width: 10),
              TextButton(onPressed: () {}, child: Text("Dismiss")),
            ],
          )
        ],
      ),
    ),
  );
}

Widget _buildLearningCards() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLearningCard("Mathematics", "50% Completed",'assets/icons/mathematics.svg' , 0.5, Colors.blue),
        _buildLearningCard("Chemistry", "55% Completed", 'assets/icons/chemistrysvg.svg', 0.55, Colors.green),
        _buildLearningCard("Physics", "60% Completed", 'assets/icons/physics.svg', 0.6, Colors.red),
      ],
    ),
  );
}

Widget _buildLearningCard(String title, String progress, String icon, double percent, Color col) {
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
            center:SvgPicture.asset(icon, width: 40,  height: 40,),
            //Icon(icon, size: 40, color: col),
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
  return SingleChildScrollView(scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPlannerCard("ToDo List", 'assets/icons/todo.svg'),
        _buildPlannerCard("Schedules", 'assets/icons/schedule.svg'),
        _buildPlannerCard("Set Goals", 'assets/icons/goal.svg'),
      ],
    ),
  );
}
Widget _buildTipOfTheDay() {
  return Container(
    height: 100,
    color: Colors.blue[50],
    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text('Study Tip of the Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
          SizedBox(height: 15,),
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber,),
              SizedBox(width: 10),

              Expanded(
                child: Text("Studying for 30 minutes every day is more effective than cramming for hours the night before!"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildPlannerCard(String title, String path) {
  return SizedBox(
    width: 150,
    height: 160,
    child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(path, width: 50, height: 50),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}


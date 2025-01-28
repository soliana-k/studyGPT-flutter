import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
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

class StudyGPTHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        title: Text('StudyGPT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.account_circle, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, John', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildScheduleCard(),
            SizedBox(height: 20),
            Text("Let's start Learning!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildLearningCards(),
            SizedBox(height: 20),
            Text("Academic Planners", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildChallengeCard("Maths", "Solve for X:\n2x + 3 = 11"),
        _buildChallengeCard("Physics", "What is the formula for Kinetic Energy?"),
      ],
    );
  }
  Widget _buildChallengeCard(String subject, String question) {
    return Expanded(
      child: Card(
        color: subject == "Maths" ? Colors.blue : Colors.red,
        child: Padding(
          padding: EdgeInsets.all(12.0),
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
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildLearningCard("Mathematics", "50%", Icons.calculate, 0.5, Colors.blue),
      _buildLearningCard("Chemistry", "55%", Icons.science, 0.55, Colors.green),
      _buildLearningCard("Physics", "60%", Icons.waves, 0.6, Colors.red),
    ],
  );
}

Widget _buildLearningCard(String title, String progress, IconData icon, double percent, Color col) {
  return Expanded(
    child: Card(

      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 5.0,
              percent: percent,
              center: Icon(icon, size: 40, color: col),
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
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildPlannerCard("ToDo List", FontAwesomeIcons.listCheck),
      _buildPlannerCard("Schedules", Icons.calendar_month),
      _buildPlannerCard("Set Goals", Icons.track_changes),
    ],
  );
}
Widget _buildTipOfTheDay() {
  return Card(
    color: Colors.blue[50],
    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text("Study Tip of the Day: Studying for 30 minutes every day is more effective than cramming for hours the night before!"),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPlannerCard(String title, IconData icon) {
  return Expanded(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );
}


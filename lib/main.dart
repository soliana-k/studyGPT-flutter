import 'package:flutter/material.dart';

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
        title: Text("StudyGPT", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        actions: [Icon(Icons.search, color: Colors.black), SizedBox(width: 10)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, John",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Schedule Learning Time Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Schedule learning time\n\nLorem ipsum dolor sit amet consectetur. Suspendisse integer nibh volutpat quis pulvinar.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Schedule"),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("Dismiss", style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 24),
            // Learning Section
            Text(
              "Let's start Learning!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LearningCard("Mathematics", "50%", Icons.calculate, Colors.blue),
                LearningCard("Chemistry", "55%", Icons.science, Colors.green),
                LearningCard("Physics", "60%", Icons.bolt, Colors.red),
              ],
            ),
            SizedBox(height: 24),
            // Academic Planners Section
            Text(
              "Academic Planners",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PlannerCard("ToDo List", Icons.checklist),
                PlannerCard("Schedules", Icons.calendar_today),
                PlannerCard("Set Goals", Icons.flag),
              ],
            ),
            SizedBox(height: 24),
            // Study Tip of the Day Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Study Tip of the Day\n\nDid you know? Studying for 30 minutes every day is more effective than cramming for hours the night before!",
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 24),
            // Daily Challenges Section
            Text(
              "Daily Challenges 🏆",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChallengeCard("Maths", "Solve for X:\n2x + 3 = 11", Colors.blue),
                ChallengeCard("Physics", "What is the formula for Kinetic Energy?", Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LearningCard extends StatelessWidget {
  final String title;
  final String progress;
  final IconData icon;
  final Color color;

  LearningCard(this.title, this.progress, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          SizedBox(height: 10),
          Text(progress, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class PlannerCard extends StatelessWidget {
  final String title;
  final IconData icon;

  PlannerCard(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[700], size: 30),
          SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  ChallengeCard(this.title, this.description, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 10),
            Text(description, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int totalReadingHours = 0;
  int totalQuizzesCompleted = 0;
  int totalPromptsUsed = 0;
  Map<String, double> subjectPerformance = {};
  List<WeeklyProgress> weeklyProgress = [];
  List<Recommendation> recommendations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData() async {
    try {

      final interactionsResponse = await http.get(
        Uri.parse('http://56.228.80.139/api/analytics/interactions/'),
      );
      final quizResponse = await http.get(
        Uri.parse('http://56.228.80.139/api/analytics/quiz-performance/?user_id=1&paginate_by=week'),
      );
      final aiUsageResponse = await http.get(
        Uri.parse('http:// 192.168.205.126:8000/api/analytics/ai-usage/?user_id=1&paginate_by=month'),
      );
      final recommendationsResponse = await http.get(
        Uri.parse('http:// 192.168.205.126:8000/api/feedback/recommendations/'),
      );

      if (interactionsResponse.statusCode == 200 &&
          quizResponse.statusCode == 200 &&
          aiUsageResponse.statusCode == 200 &&
          recommendationsResponse.statusCode == 200) {
        final interactionsData = jsonDecode(interactionsResponse.body);
        final quizData = jsonDecode(quizResponse.body);
        final aiUsageData = jsonDecode(aiUsageResponse.body);
        final recommendationsData = jsonDecode(recommendationsResponse.body);

        // Process interactions data
        final monthData = interactionsData['month']['2025-06'];
        final totalMinutes = monthData['total_time_spent'] ?? 0;
        final byEbook = interactionsData['by_ebook'];

        // Calculate weekly progress
        Map<String, int> dailyHours = {};
        for (var interaction in monthData['interactions']) {
          final date = DateTime.parse(interaction['date']);
          final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
          final timeSpent = interaction['time_spent'];
          int hours = 0;
          if (timeSpent is num) {
            hours = (timeSpent ~/ 60).toInt();
          } else if (timeSpent is String) {
            hours = (int.parse(timeSpent) ~/ 60).toInt();
          }
          dailyHours[day] = (dailyHours[day] ?? 0) + hours;
        }

        // Calculate subject performance
        Map<String, double> performance = {};
        for (var ebook in byEbook.values) {
          String title = ebook['title'];
          final timeSpent = ebook['total_time_spent'] is num
              ? ebook['total_time_spent'].toDouble()
              : double.parse(ebook['total_time_spent'].toString());
          performance[title] = timeSpent / 60.0;
        }

        setState(() {
          totalReadingHours = totalMinutes is num
              ? totalMinutes ~/ 60
              : int.parse(totalMinutes.toString()) ~/ 60;
          totalQuizzesCompleted = quizData['total_quizzes'] ?? 0;
          totalPromptsUsed = aiUsageData['month']['2025-05']['conversation_count'] ?? 0;
          subjectPerformance = performance;
          weeklyProgress = dailyHours.entries
              .map((e) => WeeklyProgress(e.key, e.value))
              .toList();
          recommendations = recommendationsData is List
              ? recommendationsData
              .map((item) => Recommendation(item['title'], item['content']))
              .toList()
              : [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Analytics', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            SizedBox(height: 24),
            _buildSubjectPerformanceChart(),
            SizedBox(height: 24),
            _buildWeeklyProgressChart(),
            SizedBox(height: 24),
            _buildStudyRecommendations(),
            SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.timer,
            value: '$totalReadingHours hrs',
            label: 'Total Reading',
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.quiz,
            value: totalQuizzesCompleted.toString(),
            label: 'Quizzes Done',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.chat_bubble,
            value: totalPromptsUsed.toString(),
            label: 'Prompts Used',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformanceChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Your time spent across different subjects (hours)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[300], // Placeholder for chart
              child: Center(child: Text('Chart Placeholder')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Study Hours',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Your study pattern this week',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              color: Colors.grey[300], // Placeholder for chart
              child: Center(child: Text('Chart Placeholder')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyRecommendations() {
    var sortedSubjects = subjectPerformance.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    String weakestSubject = sortedSubjects.isNotEmpty
        ? sortedSubjects.first.key
        : 'No data';
    String strongestSubject = sortedSubjects.isNotEmpty
        ? sortedSubjects.last.key
        : 'No data';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            ...recommendations.map((rec) => Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.blue),
                  title: Text(rec.title),
                  subtitle: Text(rec.content),
                ),
                Divider(),
              ],
            )),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Focus Area'),
              subtitle: Text('Your weakest subject is $weakestSubject. Consider spending more time on this topic.'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.star, color: Colors.green),
              title: Text('Strength'),
              subtitle: Text('You excel in $strongestSubject. Try more advanced materials in this area.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            _ActivityItem(
              icon: Icons.quiz,
              title: 'Completed AI Fundamentals Quiz',
              subtitle: 'Scored 91% on AI Fundamentals',
              time: '2025-05-31',
              color: Colors.green,
            ),
            Divider(),
            _ActivityItem(
              icon: Icons.book,
              title: 'Read Biology',
              subtitle: 'Read 65 pages',
              time: '2025-06-02',
              color: Colors.blue,
            ),
            Divider(),
            _ActivityItem(
              icon: Icons.chat,
              title: 'Asked AI Prompt',
              subtitle: 'Quantum computing explained simply',
              time: '2025-05-09',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class SubjectData {
  final String subject;
  final double score;

  SubjectData(this.subject, this.score);
}

class WeeklyProgress {
  final String day;
  final int hours;

  WeeklyProgress(this.day, this.hours);
}

class Recommendation {
  final String title;
  final String content;

  Recommendation(this.title, this.content);
}
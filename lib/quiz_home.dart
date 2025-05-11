import 'package:flutter/material.dart';
import 'quiz_chapters.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizHome extends StatefulWidget {
  const QuizHome({Key? key}) : super(key: key);

  @override
  _QuizHomeState createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // User status
  double averageResponseTime = 0.0;
  int correctAnswers = 0;
  double successRate = 0.0;
  bool isLoadingStats = true;
  String statsError = '';

  // Subjects data
  List<Map<String, dynamic>> subjects = [];
  bool isLoadingSubjects = true;
  String subjectsError = '';

  final int userGradeLevel = 6;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    _fetchUserStats();
    _fetchSubjects();
  }

  Future<void> _fetchUserStats() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        averageResponseTime = 12.5;
        correctAnswers = 34;
        successRate = 81.0;
        isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        statsError = 'Failed to load stats. Please try again.';
        isLoadingStats = false;
      });
    }
  }

  Future<void> _fetchSubjects() async {
    try {
      final response = await http.get(
        Uri.parse('http://56.228.80.139/api/quiz/books/grade/12/ '),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // define  list of  colors for each subject
        final List<Color> subjectColors = [
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.teal,
          Colors.indigo,
          Colors.brown,
          Colors.pink,
        ];

        setState(() {
          subjects = data.map((subject) {
            // Assign a color from the list
            final colorIndex = data.indexOf(subject) % subjectColors.length;
            return {
              'id': subject['id'],
              'name': subject['name'],
              'gradeLevel': subject['gradeLevel'],
              'color': subjectColors[colorIndex],
            };
          }).toList();
          isLoadingSubjects = false;
        });
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      setState(() {
        subjectsError = 'Failed to load subjects. Please try again.';
        isLoadingSubjects = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF007BFF),
        elevation: 0,
        title: const Text(
          'Quiz',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Section
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007BFF), Color(0xFF00B4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007BFF).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )],
                  ),
                  child: isLoadingStats
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : statsError.isNotEmpty
                      ? Center(
                    child: Text(
                      statsError,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressItem(Icons.timer, '${averageResponseTime.toStringAsFixed(1)}s', 'Response Time'),
                      _buildProgressItem(Icons.check_circle_outline, '$correctAnswers', 'Correct'),
                      _buildProgressItem(Icons.show_chart, '${successRate.toStringAsFixed(1)}%', 'Success Rate'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Subjects Section
              const Text(
                'Available Subjects',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007BFF),
                ),
              ),
              const SizedBox(height: 16),
              isLoadingSubjects
                  ? const Center(child: CircularProgressIndicator())
                  : subjectsError.isNotEmpty
                  ? Center(child: Text(subjectsError))
                  : _buildSubjectsGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 36),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _SubjectCard(
          title: subject['name'],
          color: subject['color'],
          gradeLevel: subject['gradeLevel'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizChaptersScreen(
                  subject: subject['name'],
                  subjectId: subject['id'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SubjectCard extends StatefulWidget {
  final String title;
  final Color color;
  final int gradeLevel;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.color,
    required this.gradeLevel,
    required this.onTap,
  });

  @override
  _SubjectCardState createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.book, color: Colors.white.withOpacity(0.9), size: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grade ${widget.gradeLevel}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ElevatedButton(
                    onPressed: widget.onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: widget.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
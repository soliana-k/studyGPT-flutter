import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizChaptersScreen extends StatefulWidget {
  final String subject;
  final int subjectId;

  const QuizChaptersScreen({
    Key? key,
    required this.subject,
    required this.subjectId,
  }) : super(key: key);

  @override
  _QuizChaptersScreenState createState() => _QuizChaptersScreenState();
}

class _QuizChaptersScreenState extends State<QuizChaptersScreen> {
  List<Map<String, dynamic>> chapters = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChapters();
  }

  Future<void> _fetchChapters() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final mockChapters = {
        1: [ // Physics
          {
            'id': 101,
            'name': 'Chapter 1: Mechanics',
            'description': 'Forces, motion, and energy',
            'questionCount': 15,
          },
          {
            'id': 102,
            'name': 'Chapter 2: Thermodynamics',
            'description': 'Heat and energy transfer',
            'questionCount': 12,
          },
          {
            'id': 103,
            'name': 'Chapter 3: Electromagnetism',
            'description': 'Electricity and magnetism',
            'questionCount': 18,
          },
        ],
        2: [ // Chemistry
          {
            'id': 201,
            'name': 'Chapter 1: Atomic Structure',
            'description': 'Atoms and elements',
            'questionCount': 10,
          },
          {
            'id': 202,
            'name': 'Chapter 2: Chemical Bonding',
            'description': 'Molecular structures',
            'questionCount': 14,
          },
        ],
        3: [ // Math
          {
            'id': 301,
            'name': 'Chapter 1: Algebra',
            'description': 'Equations and functions',
            'questionCount': 20,
          },
          {
            'id': 302,
            'name': 'Chapter 2: Calculus',
            'description': 'Derivatives and integrals',
            'questionCount': 16,
          },
        ],
        4: [ // Biology
          {
            'id': 401,
            'name': 'Chapter 1: Cell Biology',
            'description': 'Cell structure and function',
            'questionCount': 12,
          },
          {
            'id': 402,
            'name': 'Chapter 2: Genetics',
            'description': 'DNA and heredity',
            'questionCount': 15,
          },
        ],
      };

      setState(() {
        chapters = List<Map<String, dynamic>>.from(mockChapters[widget.subjectId] ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load chapters. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Chapters'),
        backgroundColor: const Color(0xFF007BFF),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a chapter to start quiz:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (chapters.isEmpty)
                  const Center(
                    child: Text('No chapters available for this subject'),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        return _buildChapterCard(chapters[index]);
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterCard(Map<String, dynamic> chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                subject: widget.subject,
                chapterId: chapter['id'],
                chapterName: chapter['name'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      chapter['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${chapter['questionCount']} Qs',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF007BFF),
                  ),
                ],
              ),
              if (chapter['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  chapter['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Start Quiz',
                    style: TextStyle(
                      color: Color(0xFF007BFF),
                      fontWeight: FontWeight.bold,
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
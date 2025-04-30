import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';

class TriviaScreen extends StatefulWidget {
  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  Future<List<Map<String, String>>>? _questions;

  @override
  void initState() {
    super.initState();
    _questions = fetchTriviaQuestions('science'); // You can change category
  }

  // Fetch trivia questions from Open Trivia Database
  Future<List<Map<String, String>>> fetchTriviaQuestions(String category) async {
    final url = Uri.parse('https://opentdb.com/api.php?amount=10&category=17'); // Category 17 = Science
    final response = await http.get(url);
    final unescape = HtmlUnescape();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Map<String, String>> questions = [];
      for (var result in data['results']) {
        questions.add({
          'question': unescape.convert(result['question']),
          'correct_answer': unescape.convert(result['correct_answer']),
        });
      }
      return questions;
    } else {
      throw Exception('Failed to load trivia questions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions available.'));
          }

          var questions = snapshot.data!;

          return _buildDailyChallengesWithQuestions(questions);
        },

    );
  }

  Widget _buildDailyChallengesWithQuestions(List<Map<String, String>> questions) {
    final total = questions.length;
    final count = 4;
    final dayOffset = DateTime.now().day % total;

    final dailyQuestions = List.generate(count, (i) {
      return questions[(dayOffset + i) % total];
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        height: 200, // This is CRITICAL to avoid infinite height in horizontal scroll
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: dailyQuestions.length,
          separatorBuilder: (_, __) => SizedBox(width: 12),
          itemBuilder: (context, index) {
            final q = dailyQuestions[index];
            return ChallengeCard(
              subject: "Science",
              question: q['question'] ?? 'No question',
              answer: q['correct_answer'] ?? 'No answer',
            );
          },
        ),
      ),
    );
  }

}
class ChallengeCard extends StatefulWidget {
  final String subject;
  final String question;
  final String answer;

  const ChallengeCard({
    required this.subject,
    required this.question,
    required this.answer,
    super.key,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Fixed width for horizontal card
      child: Card(
        color: widget.subject == "Maths" ? Colors.blue : Colors.teal,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.subject,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(widget.question, style: TextStyle(color: Colors.white)),
                ),
              ),
              if (_showAnswer) ...[
                SizedBox(height: 10),
                Text("Answer: ${widget.answer}",
                    style: TextStyle(
                        color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
              ],
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: Text(_showAnswer ? "Hide Answer" : "Show Answer",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

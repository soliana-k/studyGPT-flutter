import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final int chapterId;
  final String chapterName;

  const QuizScreen({
    Key? key,
    required this.subject,
    required this.chapterId,
    required this.chapterName,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  String errorMessage = '';
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool answerSubmitted = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuizQuestions();
  }

  Future<void> _fetchQuizQuestions() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        questions = [
          {
            'question': 'What is the SI unit of force?',
            'options': ['Joule', 'Newton', 'Watt', 'Pascal'],
            'correctAnswer': 1,
            'explanation': 'The SI unit of force is Newton (N), named after Sir Isaac Newton.'
          },
          {
            'question': 'Which law states that every action has an equal and opposite reaction?',
            'options': [
              'Newton\'s First Law',
              'Newton\'s Second Law',
              'Newton\'s Third Law',
              'Law of Gravitation'
            ],
            'correctAnswer': 2,
            'explanation': 'Newton\'s Third Law states that for every action, there is an equal and opposite reaction.'
          },
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load quiz questions. Please try again.';
        isLoading = false;
      });
    }
  }

  void _submitAnswer() {
    if (selectedAnswerIndex == null) return;

    setState(() {
      answerSubmitted = true;
      if (selectedAnswerIndex == questions[currentQuestionIndex]['correctAnswer']) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      currentQuestionIndex++;
      selectedAnswerIndex = null;
      answerSubmitted = false;
    });
  }

  void _finishQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('Your score: $score/${questions.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review'),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        backgroundColor: const Color(0xFF007BFF),
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : questions.isEmpty
              ? const Center(child: Text('No questions available'))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF007BFF),
              ),
              const SizedBox(height: 20),
              Text(
                'Question ${currentQuestionIndex + 1}/${questions.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                questions[currentQuestionIndex]['question'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ...List.generate(
                questions[currentQuestionIndex]['options'].length,
                    (index) => _buildOptionCard(
                  questions[currentQuestionIndex]['options'][index],
                  index,
                ),
              ),
              const Spacer(),
              if (answerSubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAnswerIndex == questions[currentQuestionIndex]['correctAnswer']
                            ? 'Correct!'
                            : 'Incorrect',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: selectedAnswerIndex == questions[currentQuestionIndex]['correctAnswer']
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        questions[currentQuestionIndex]['explanation'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: answerSubmitted
                      ? currentQuestionIndex < questions.length - 1
                      ? _nextQuestion
                      : _finishQuiz
                      : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    answerSubmitted
                        ? currentQuestionIndex < questions.length - 1
                        ? 'Next Question'
                        : 'Finish Quiz'
                        : 'Submit Answer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildOptionCard(String option, int index) {
    bool isCorrect = index == questions[currentQuestionIndex]['correctAnswer'];
    bool isSelected = selectedAnswerIndex == index;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (answerSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFF007BFF).withOpacity(0.1);
      borderColor = const Color(0xFF007BFF);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: answerSubmitted ? null : () {
          setState(() {
            selectedAnswerIndex = index;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (answerSubmitted
                      ? (isCorrect
                      ? Colors.green
                      : Colors.red)
                      : const Color(0xFF007BFF))
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade400,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
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
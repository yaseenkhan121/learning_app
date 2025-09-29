import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;

  const QuizScreen({super.key, required this.courseId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;

  // Example static quiz (later we can move to Firestore)
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "What does UI stand for?",
      "options": ["User Internet", "User Interface", "Unified Input", "Unique Idea"],
      "answer": "User Interface",
    },
    {
      "question": "Which tool is best for prototyping?",
      "options": ["Photoshop", "Figma", "Excel", "Word"],
      "answer": "Figma",
    },
    {
      "question": "Which color is best for CTAs?",
      "options": ["Grey", "Blue", "Transparent", "Random"],
      "answer": "Blue",
    },
  ];

  void _checkAnswer(String selected) {
    if (_answered) return;
    setState(() {
      _answered = true;
      if (selected == _questions[_currentQuestion]["answer"]) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _answered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed! 🎉"),
        content: Text("Your Score: $_score / ${_questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to previous screen
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Quiz"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${_currentQuestion + 1} of ${_questions.length}",
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            Text(
              question["question"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // Options
            ...question["options"].map<Widget>((opt) {
              final isCorrect = opt == question["answer"];
              final isSelected = _answered && opt == question["answer"];
              return GestureDetector(
                onTap: () => _checkAnswer(opt),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _answered
                        ? (isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2))
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.green
                          : Colors.blueGrey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            ElevatedButton(
              onPressed: _answered ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentQuestion == _questions.length - 1
                    ? "Finish Quiz"
                    : "Next Question",
                style: const TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}

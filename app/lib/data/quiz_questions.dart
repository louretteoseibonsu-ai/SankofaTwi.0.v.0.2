class QuizQuestion {
  final String category;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;
  const QuizQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });
}

const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    category: 'Greetings & Basics',
    question: "What is the primary meaning of the word 'Akwaaba'?",
    options: ['Goodbye', 'Thank you', 'Welcome', 'Good morning'],
    answer: 'Welcome',
    explanation: "Akwaaba is the legendary Ghanaian word for 'Welcome', showered upon guests to show hospitality.",
  ),
  QuizQuestion(
    category: 'Greetings & Basics',
    question: "How do you say 'Thank you' in Asante Twi?",
    options: ['Akwaaba', 'Medaase', 'Kose', 'Ete sen?'],
    answer: 'Medaase',
    explanation: "'Medaase' means thank you. It represents giving thanks to someone's kindness.",
  ),
  QuizQuestion(
    category: 'Day Names',
    question: 'If a girl is born on Saturday (Memeneda), what is her traditional Akan day name?',
    options: ['Akua', 'Ama', 'Adwoa', 'Yaa'],
    answer: 'Ama',
    explanation: 'Ama is the traditional name for a girl born on Saturday. A boy born on Saturday is named Kwame.',
  ),
  QuizQuestion(
    category: 'Numbers & Counting',
    question: 'Which of the following is the Twi word for the number Five (5)?',
    options: ['Mmienu', 'Enum', 'Edu', 'Ensia'],
    answer: 'Enum',
    explanation: 'Enum is 5. Baako (1), Mmienu (2), Mmiensa (3), Enan (4), Enum (5).',
  ),
  QuizQuestion(
    category: 'Cultural Wisdom',
    question: "What is the literal translation of the symbol and word 'Sankofa'?",
    options: ['Except God', 'Go back and get it', "Ram's horns", 'Humility and Strength'],
    answer: 'Go back and get it',
    explanation: "Sankofa means 'to return and fetch it' (san - to return; ko - to go; fa - to look/take). It represents learning from our history.",
  ),
  QuizQuestion(
    category: 'Conversational Basics',
    question: "What does 'Kom de me' translate to?",
    options: ['I am happy', 'I am tired', 'I am hungry', 'I am going home'],
    answer: 'I am hungry',
    explanation: "'Kom de me' literally translates to 'hunger holds/afflicts me', meaning 'I am hungry'.",
  ),
];

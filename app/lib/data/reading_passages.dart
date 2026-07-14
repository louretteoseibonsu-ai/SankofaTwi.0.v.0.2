import 'lesson_content.dart' show Challenge;

/// A short reading passage: Twi lines (each matches a bundled audio clip so
/// pronunciation plays free), an English translation, and comprehension
/// questions. Built from vocabulary the app already teaches, so the Twi is
/// accurate and speakable.
class ReadingPassage {
  final String id;
  final String title;
  final String level; // Beginner / Elementary / …
  final List<String> lines;
  final String english;
  final List<Challenge> questions;
  const ReadingPassage({
    required this.id,
    required this.title,
    required this.level,
    required this.lines,
    required this.english,
    required this.questions,
  });

  /// Correct answers needed to pass (60%, rounded up).
  int get passMark => (questions.length * 0.6).ceil();
}

const List<ReadingPassage> kReadingPassages = [
  ReadingPassage(
    id: 'read_greetings_family',
    title: 'Akwaaba — Meeting Ama',
    level: 'Beginner',
    lines: [
      'Akwaaba! Yɛma wo akwaaba.',
      'Wo ho te sɛn?',
      'Me ho yɛ',
      'Medaase',
      "Me na ne m'agya wɔ fie.",
      'Onua baa baako wɔ me.',
      'Me abusua mu nnipa dɔɔso.',
    ],
    english: 'Welcome! We welcome you. How are you? I am fine. Thank you. '
        'My mother and my father are at home. I have one sister. '
        'There are many people in my family.',
    questions: [
      Challenge(
        'How does the speaker say they are feeling?',
        ['I am fine (Me ho yɛ)', 'I am tired', 'I am hungry', 'I am busy'],
        0,
      ),
      Challenge(
        'Who is at home (fie)?',
        ['Mother and father', 'Brother and sister', 'Grandparents', 'Friends'],
        0,
      ),
      Challenge(
        'How many sisters does the speaker have?',
        ['One', 'Two', 'Three', 'None'],
        0,
      ),
      Challenge(
        'What does “Medaase” mean?',
        ['Thank you', 'Welcome', 'Sorry', 'Please'],
        0,
      ),
    ],
  ),
  ReadingPassage(
    id: 'read_numbers',
    title: 'Yɛkan — Let’s Count',
    level: 'Beginner',
    lines: [
      'Baako, mmienu, mmiɛnsa.',
      'ɛnan',
      'enum',
      'Me wɔ nnipa baako.',
    ],
    english: 'One, two, three. Four. Five. I have one person.',
    questions: [
      Challenge(
        'What number is “mmienu”?',
        ['Two', 'One', 'Three', 'Five'],
        0,
      ),
      Challenge(
        'What number is “enum”?',
        ['Five', 'Four', 'Six', 'Ten'],
        0,
      ),
      Challenge(
        '“Baako” means…',
        ['One', 'Two', 'Zero', 'Many'],
        0,
      ),
      Challenge(
        '“Mmiɛnsa” is which number?',
        ['Three', 'Two', 'Four', 'Six'],
        0,
      ),
    ],
  ),
  ReadingPassage(
    id: 'read_time_of_day',
    title: 'Nkyea — Greetings Through the Day',
    level: 'Elementary',
    lines: [
      'Maakye',
      'Maaha',
      'Maadwo',
    ],
    english: 'Good morning. Good afternoon. Good evening. '
        '(At every time of day, we greet one another.)',
    questions: [
      Challenge(
        'Which greeting is used in the morning (anɔpa)?',
        ['Maakye', 'Maaha', 'Maadwo', 'Medaase'],
        0,
      ),
      Challenge(
        '“Maadwo” is used in the…',
        ['Evening', 'Morning', 'Afternoon', 'Midnight'],
        0,
      ),
      Challenge(
        '“Maaha” greets someone in the…',
        ['Afternoon', 'Morning', 'Evening', 'Night'],
        0,
      ),
    ],
  ),
  ReadingPassage(
    id: 'read_at_the_door',
    title: 'Bra Mu — At the Door',
    level: 'Elementary',
    lines: [
      'Akwaaba, bra mu.',
      'Mepa wo kyɛw',
      'Wo ho te sɛn?',
      'Me ho yɛ',
      'Medaase',
      'Aane',
    ],
    english: 'Welcome, come in. Please. How are you? I am fine. Thank you. Yes.',
    questions: [
      Challenge(
        '“Bra mu” invites you to…',
        ['Come in', 'Sit down', 'Eat', 'Leave'],
        0,
      ),
      Challenge(
        '“Mepa wo kyɛw” means…',
        ['Please / excuse me', 'Thank you', 'Welcome', 'Goodbye'],
        0,
      ),
      Challenge(
        'The reply “Me ho yɛ” means…',
        ['I am fine', 'I am here', 'I am coming', 'I am hungry'],
        0,
      ),
      Challenge(
        '“Aane” means…',
        ['Yes', 'No', 'Maybe', 'Please'],
        0,
      ),
    ],
  ),
];

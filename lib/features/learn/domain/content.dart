import 'cefr.dart';

/// Multiple-choice question. `correct` is stored separately; options are
/// shuffled at runtime so the answer position is never predictable.
class Question {
  final String prompt;
  final String correct;
  final List<String> wrong;
  const Question(this.prompt, this.correct, this.wrong);
}

class Lesson {
  final String id;
  final String title;
  final List<Question> questions;
  const Lesson(this.id, this.title, this.questions);
}

/// The whole curriculum. A1 is complete; A2-C2 have a starter lesson each.
/// Add lessons here (or later load them from JSON/Firestore) and the
/// progression system adapts automatically.
final Map<Cefr, List<Lesson>> curriculum = {
  Cefr.a1: [
    Lesson('l1', 'Greetings', [
      Question('Which greeting do you use in the morning?', 'Good morning',
          ['Good night', 'Goodbye', 'Good afternoon']),
      Question('Complete: "___ name is Sara."', 'My', ['I', 'Me', 'Am']),
      Question('Someone says "How are you?" Best answer:',
          'I am fine, thank you.', ['My name is Tom.', 'Good night.', 'See you.']),
      Question('Which sentence is correct?', 'I am Ahmed.',
          ['I is Ahmed.', 'I are Ahmed.', 'Me am Ahmed.']),
      Question('You say this when you leave:', 'Goodbye',
          ['Hello', 'Welcome', 'Please']),
    ]),
    Lesson('l2', 'Numbers & Colors', [
      Question('What is 7 in English?', 'Seven', ['Six', 'Eleven', 'Seventeen']),
      Question('Which number is "twelve"?', '12', ['2', '20', '21']),
      Question('The sky is ___ on a sunny day.', 'blue', ['green', 'black', 'red']),
      Question('Which color is a banana?', 'Yellow', ['Purple', 'Pink', 'Brown']),
      Question('What is 15 in English?', 'Fifteen', ['Fifty', 'Fourteen', 'Five']),
    ]),
    Lesson('l3', 'Verb "to be" & Family', [
      Question('She ___ my sister.', 'is', ['am', 'are', 'be']),
      Question('They ___ students.', 'are', ['is', 'am', 'be']),
      Question("Your mother's mother is your ___.", 'grandmother',
          ['aunt', 'sister', 'daughter']),
      Question('I ___ a teacher.', 'am', ['is', 'are', 'be']),
      Question("Your father's son is your ___.", 'brother',
          ['uncle', 'cousin', 'father']),
    ]),
    Lesson('l4', 'Everyday Objects', [
      Question('You use a ___ to write.', 'pen', ['spoon', 'shoe', 'window']),
      Question('Which one is a fruit?', 'Apple', ['Chair', 'Table', 'Door']),
      Question('Plural of "book":', 'books', ['bookes', 'bookies', 'book']),
      Question('This is ___ apple.', 'an', ['a', 'two', 'many']),
      Question('Where do you sleep?', 'In a bed',
          ['In a car', 'In a pen', 'In a cup']),
    ]),
  ],
  Cefr.a2: [
    Lesson('l1', 'Daily Life & Past Tense', [
      Question('I usually ___ up at 7 a.m.', 'get', ['gets', 'getting', 'got']),
      Question('She ___ to school yesterday.', 'went', ['go', 'goes', 'going']),
      Question('There ___ two apples on the table.', 'are', ['is', 'am', 'be']),
      Question('I am ___ than my brother.', 'taller',
          ['tallest', 'more tall', 'most tall']),
    ]),
  ],
  Cefr.b1: [
    Lesson('l1', 'Experiences & Future', [
      Question('I have lived here ___ 2020.', 'since', ['for', 'during', 'from']),
      Question('If it rains tomorrow, we ___ at home.', 'will stay',
          ['stayed', 'have stayed', 'stays']),
      Question('He is good ___ playing chess.', 'at', ['in', 'on', 'for']),
      Question("I'm looking forward to ___ you.", 'seeing', ['see', 'saw', 'seen']),
    ]),
  ],
  Cefr.b2: [
    Lesson('l1', 'Advanced Grammar', [
      Question('If I ___ you, I would apologize.', 'were',
          ['am', 'be', 'will be']),
      Question('By next year, she ___ the course.', 'will have finished',
          ['finished', 'has finished', 'is finishing']),
      Question('Despite ___ tired, he kept working.', 'being',
          ['be', 'been', 'is']),
      Question('He suggested ___ earlier.', 'leaving',
          ['to leave', 'leave', 'left']),
    ]),
  ],
  Cefr.c1: [
    Lesson('l1', 'Nuance & Idioms', [
      Question('Hardly ___ arrived when it started to rain.', 'had she',
          ['she had', 'did she', 'she has']),
      Question('"Ubiquitous" means:', 'found everywhere',
          ['very rare', 'extremely old', 'easily broken']),
      Question('Not only ___ late, but he also forgot the documents.', 'was he',
          ['he was', 'he is', 'is he']),
      Question('"To beat around the bush" means to:', 'avoid the main point',
          ['hit a plant', 'win easily', 'speak loudly']),
    ]),
  ],
  Cefr.c2: [
    Lesson('l1', 'Mastery', [
      Question('"Ephemeral" means:', 'lasting a very short time',
          ['extremely important', 'deeply hidden', 'hard to understand']),
      Question('Choose the correct sentence:', 'Had I known, I would have helped.', [
        'If I would have known, I would have helped.',
        'Had I knew, I would helped.',
        'If I had know, I would help.'
      ]),
      Question('"Ostensibly" means:', 'apparently, but perhaps not truly',
          ['secretly', 'completely', 'rarely']),
      Question('"A double-edged sword" is something that:',
          'has both benefits and drawbacks',
          ['is very sharp', 'is dangerous only', 'is very rare']),
    ]),
  ],
};

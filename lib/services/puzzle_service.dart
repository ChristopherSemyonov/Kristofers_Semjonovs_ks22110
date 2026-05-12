import 'package:latlong2/latlong.dart';

import '../models/puzzle.dart';

class PuzzleService {
  static List<Puzzle> getDemoPuzzles() {
    return const [
      Puzzle(
        id: 'puzzle_1',
        title: 'City Puzzle',
        question:
            'Kā sauc Rīgas vēsturisko centru, kas ir iekļauts UNESCO pasaules mantojuma sarakstā?',
        answer: 'vecriga',
        points: 250,
        location: LatLng(56.9496, 24.1052),
      ),
      Puzzle(
        id: 'puzzle_2',
        title: 'Blue Marker Puzzle',
        question: 'Kā sauc Latvijas galvaspilsētu?',
        answer: 'riga',
        points: 120,
        location: LatLng(56.9489, 24.1064),
      ),
      Puzzle(
        id: 'puzzle_3',
        title: 'Green Marker Puzzle',
        question: 'Pie kuras upes atrodas Rīga?',
        answer: 'daugava',
        points: 150,
        location: LatLng(56.9508, 24.1037),
      ),
    ];
  }

  static bool isAnswerCorrect({
    required Puzzle puzzle,
    required String userAnswer,
  }) {
    String normalize(String value) {
      return value
          .trim()
          .toLowerCase()
          .replaceAll('ā', 'a')
          .replaceAll('ē', 'e')
          .replaceAll('ī', 'i')
          .replaceAll('ū', 'u')
          .replaceAll('ģ', 'g')
          .replaceAll('ķ', 'k')
          .replaceAll('ļ', 'l')
          .replaceAll('ņ', 'n')
          .replaceAll('š', 's')
          .replaceAll('č', 'c')
          .replaceAll('ž', 'z');
    }

    return normalize(userAnswer) == normalize(puzzle.answer);
  }
}

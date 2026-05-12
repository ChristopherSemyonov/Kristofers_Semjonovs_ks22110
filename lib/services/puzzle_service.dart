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
}

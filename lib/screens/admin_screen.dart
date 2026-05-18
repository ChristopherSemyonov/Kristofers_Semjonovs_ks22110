import 'package:flutter/material.dart';

import '../services/admin_api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final idController = TextEditingController();
  final titleController = TextEditingController();
  final questionController = TextEditingController();
  final answerController = TextEditingController();
  final pointsController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  List<dynamic> puzzles = [];
  bool isLoadingPuzzles = true;

  String difficulty = 'EASY';
  bool isLoading = false;

  Future<void> _createPuzzle() async {
    setState(() {
      isLoading = true;
    });

    try {
      await AdminApiService.createPuzzle(
        id: idController.text.trim(),
        title: titleController.text.trim(),
        question: questionController.text.trim(),
        answer: answerController.text.trim(),
        points: int.parse(pointsController.text.trim()),
        difficulty: difficulty,
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mīkla veiksmīgi pievienota.')),
      );

      idController.clear();
      titleController.clear();
      questionController.clear();
      answerController.clear();
      pointsController.clear();
      latitudeController.clear();
      longitudeController.clear();

      await _loadPuzzles();

      setState(() {
        difficulty = 'EASY';
      });
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    idController.dispose();
    titleController.dispose();
    questionController.dispose();
    answerController.dispose();
    pointsController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    try {
      final loadedPuzzles = await AdminApiService.fetchPuzzles();

      if (!mounted) return;

      setState(() {
        puzzles = loadedPuzzles;
        isLoadingPuzzles = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingPuzzles = false;
      });
    }
  }

  Future<void> _deletePuzzle(String puzzleId) async {
    try {
      await AdminApiService.deletePuzzle(puzzleId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mīkla veiksmīgi izdzēsta.')),
      );

      await _loadPuzzles();
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin panel',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pievieno jaunu mīklu backend datubāzei.',
            style: TextStyle(color: Color(0xFF5C4037)),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: idController,
            decoration: const InputDecoration(
              labelText: 'Puzzle ID',
              hintText: 'puzzle_13',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: questionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Question',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: answerController,
            decoration: const InputDecoration(
              labelText: 'Answer',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: pointsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Points',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: difficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'EASY', child: Text('EASY')),
              DropdownMenuItem(value: 'MEDIUM', child: Text('MEDIUM')),
              DropdownMenuItem(value: 'HARD', child: Text('HARD')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                difficulty = value;
              });
            },
          ),
          const SizedBox(height: 12),

          TextField(
            controller: latitudeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Latitude',
              hintText: '56.9496',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: longitudeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Longitude',
              hintText: '24.1052',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _createPuzzle,
              child: Text(
                isLoading ? 'Saglabā...' : 'Create puzzle',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Existing puzzles',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          if (isLoadingPuzzles)
            const Center(child: CircularProgressIndicator())
          else
            ...puzzles.map(
              (puzzle) => Card(
                child: ListTile(
                  title: Text(puzzle['title'].toString()),
                  subtitle: Text(
                    '${puzzle['difficulty']} · ${puzzle['points']} R · ${puzzle['is_active'] == 1 ? 'ACTIVE' : 'HIDDEN'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          puzzle['is_active'] == 1
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        color: puzzle['is_active'] == 1
                            ? Colors.orange
                            : Colors.green,
                        onPressed: () async {
                          if (puzzle['is_active'] == 1) {
                            await AdminApiService.hidePuzzle(
                              puzzle['id'].toString(),
                            );
                          } else {
                            await AdminApiService.unhidePuzzle(
                              puzzle['id'].toString(),
                            );
                          }

                          await _loadPuzzles();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Dzēst mīklu?'),
                                content: Text(
                                  'Vai tiešām vēlies izdzēst mīklu "${puzzle['title']}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Atcelt'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Dzēst'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete == true) {
                            await _deletePuzzle(puzzle['id'].toString());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

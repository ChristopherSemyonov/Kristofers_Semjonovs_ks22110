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
  final option1Controller = TextEditingController();
  final option2Controller = TextEditingController();
  final option3Controller = TextEditingController();
  final option4Controller = TextEditingController();
  final pointsController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  bool isEditing = false;
  String? editingPuzzleId;

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
        options: [
          option1Controller.text.trim(),
          option2Controller.text.trim(),
          option3Controller.text.trim(),
          option4Controller.text.trim(),
        ],
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
      option1Controller.clear();
      option2Controller.clear();
      option3Controller.clear();
      option4Controller.clear();
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
    option1Controller.dispose();
    option2Controller.dispose();
    option3Controller.dispose();
    option4Controller.dispose();
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

  void _fillFormForEdit(Map<String, dynamic> puzzle) {
    idController.text = puzzle['id'].toString();
    titleController.text = puzzle['title'].toString();
    questionController.text = puzzle['question'].toString();
    answerController.text = puzzle['answer'].toString();
    pointsController.text = puzzle['points'].toString();
    latitudeController.text = puzzle['latitude'].toString();
    longitudeController.text = puzzle['longitude'].toString();

    final options = puzzle['options'] as List<dynamic>?;

    option1Controller.text = options != null && options.isNotEmpty
        ? options[0].toString()
        : '';
    option2Controller.text = options != null && options.length > 1
        ? options[1].toString()
        : '';
    option3Controller.text = options != null && options.length > 2
        ? options[2].toString()
        : '';
    option4Controller.text = options != null && options.length > 3
        ? options[3].toString()
        : '';

    setState(() {
      difficulty = puzzle['difficulty'].toString();
      isEditing = true;
      editingPuzzleId = puzzle['id'].toString();
    });
  }

  Future<void> _submitPuzzleForm() async {
    if (!_validateForm()) return;

    if (isEditing && editingPuzzleId != null) {
      await AdminApiService.updatePuzzle(
        id: editingPuzzleId!,
        title: titleController.text.trim(),
        question: questionController.text.trim(),
        answer: answerController.text.trim(),
        options: [
          option1Controller.text.trim(),
          option2Controller.text.trim(),
          option3Controller.text.trim(),
          option4Controller.text.trim(),
        ],
        points: int.parse(pointsController.text.trim()),
        difficulty: difficulty,
        latitude: double.parse(latitudeController.text.trim()),
        longitude: double.parse(longitudeController.text.trim()),
      );
    } else {
      await _createPuzzle();
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mīkla veiksmīgi atjaunināta.')),
    );

    idController.clear();
    titleController.clear();
    questionController.clear();
    answerController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();
    pointsController.clear();
    latitudeController.clear();
    longitudeController.clear();

    setState(() {
      difficulty = 'EASY';
      isEditing = false;
      editingPuzzleId = null;
    });

    await _loadPuzzles();
  }

  void _cancelEdit() {
    idController.clear();
    titleController.clear();
    questionController.clear();
    answerController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();
    pointsController.clear();
    latitudeController.clear();
    longitudeController.clear();

    setState(() {
      difficulty = 'EASY';
      isEditing = false;
      editingPuzzleId = null;
    });
  }

  bool _validateForm() {
    if (idController.text.trim().isEmpty ||
        titleController.text.trim().isEmpty ||
        questionController.text.trim().isEmpty ||
        answerController.text.trim().isEmpty ||
        pointsController.text.trim().isEmpty ||
        latitudeController.text.trim().isEmpty ||
        longitudeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lūdzu aizpildi visus laukus.')),
      );
      return false;
    }

    if (int.tryParse(pointsController.text.trim()) == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Punktiem jābūt skaitlim.')));
      return false;
    }

    if (double.tryParse(latitudeController.text.trim()) == null ||
        double.tryParse(longitudeController.text.trim()) == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koordinātām jābūt skaitļiem.')),
      );
      return false;
    }

    return true;
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

          const Text(
            'Create / Edit Puzzle',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: idController,
            enabled: !isEditing,
            decoration: InputDecoration(
              labelText: 'Puzzle ID',
              hintText: 'puzzle_13',
              border: const OutlineInputBorder(),
              helperText: isEditing
                  ? 'ID cannot be changed while editing'
                  : null,
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
            controller: option1Controller,
            decoration: const InputDecoration(
              labelText: 'Option 1',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: option2Controller,
            decoration: const InputDecoration(
              labelText: 'Option 2',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: option3Controller,
            decoration: const InputDecoration(
              labelText: 'Option 3',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: option4Controller,
            decoration: const InputDecoration(
              labelText: 'Option 4',
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
            initialValue: difficulty,
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
              onPressed: isLoading ? null : _submitPuzzleForm,
              child: Text(
                isLoading
                    ? 'Saglabā...'
                    : isEditing
                    ? 'Update puzzle'
                    : 'Create puzzle',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          if (isEditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _cancelEdit,
                child: const Text(
                  'Cancel edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],

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
                color: puzzle['is_active'] == 1
                    ? Colors.white
                    : const Color(0xFFFFF3E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
                child: ListTile(
                  title: Text(
                    puzzle['title'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${puzzle['id']} · ${puzzle['difficulty']} · ${puzzle['points']} R · ${puzzle['is_active'] == 1 ? 'VISIBLE' : 'HIDDEN'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () {
                          _fillFormForEdit(Map<String, dynamic>.from(puzzle));
                        },
                      ),
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
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
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

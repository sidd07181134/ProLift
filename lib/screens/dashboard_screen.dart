import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, List<Map<String, dynamic>>> _workoutsByDate = {};
  Map<String, List<Map<String, dynamic>>> _mealsByDate = {};
  String _selectedMuscleGroup = 'chest'; // Default muscle group

  final List<String> _muscleGroups = [
    'chest',
    'legs',
    'back',
    'arms',
    'shoulders',
    'abs'
  ];

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<double> _generateHeaviestPRsByMuscleGroup(String muscleGroup) {
    List<double> heaviestPRs = [];
    List<String> sortedDates = _workoutsByDate.keys.toList()..sort();

    for (String date in sortedDates) {
      double maxWeight = 0;
      for (var workout in _workoutsByDate[date]!) {
        for (var exercise in workout['exercises']) {
          if (exercise['muscleGroup'] == muscleGroup) {
            double weight = exercise['weight'] as double;
            if (weight > maxWeight) {
              maxWeight = weight;
            }
          }
        }
      }
      heaviestPRs.add(maxWeight);
    }

    return heaviestPRs;
  }

  Map<String, double> _calculateTotalMacros(String dateKey) {
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    if (_mealsByDate.containsKey(dateKey)) {
      for (var meal in _mealsByDate[dateKey]!) {
        final macros = meal['macros'];
        totalProtein += macros['protein'] ?? 0.0;
        totalCarbs += macros['carbs'] ?? 0.0;
        totalFat += macros['fat'] ?? 0.0;
      }
    }

    return {
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  void _showAddWorkoutDialog() {
    final TextEditingController workoutNameController = TextEditingController();
    List<Map<String, dynamic>> exercises = [];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final TextEditingController exerciseNameController = TextEditingController();
            final TextEditingController muscleGroupController = TextEditingController();
            final TextEditingController setsController = TextEditingController();
            final TextEditingController repsController = TextEditingController();
            final TextEditingController weightController = TextEditingController();

            void _addExercise() {
              if (exerciseNameController.text.isNotEmpty &&
                  muscleGroupController.text.isNotEmpty &&
                  setsController.text.isNotEmpty &&
                  repsController.text.isNotEmpty &&
                  weightController.text.isNotEmpty) {
                setDialogState(() {
                  exercises.add({
                    'name': exerciseNameController.text,
                    'muscleGroup': muscleGroupController.text.toLowerCase(),
                    'sets': int.tryParse(setsController.text) ?? 0,
                    'reps': int.tryParse(repsController.text) ?? 0,
                    'weight': double.tryParse(weightController.text) ?? 0.0,
                  });
                });
                exerciseNameController.clear();
                muscleGroupController.clear();
                setsController.clear();
                repsController.clear();
                weightController.clear();
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('All fields must be filled out for an exercise.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text('Add Workout'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: workoutNameController,
                      decoration: InputDecoration(labelText: 'Workout Name'),
                    ),
                    SizedBox(height: 10),
                    Text('Add Exercise'),
                    TextField(
                      controller: exerciseNameController,
                      decoration: InputDecoration(labelText: 'Exercise Name'),
                    ),
                    TextField(
                      controller: muscleGroupController,
                      decoration: InputDecoration(labelText: 'Muscle Group'),
                    ),
                    TextField(
                      controller: setsController,
                      decoration: InputDecoration(labelText: 'Sets'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: repsController,
                      decoration: InputDecoration(labelText: 'Reps'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(labelText: 'Weight (kg)'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addExercise,
                      child: Text('Add Exercise'),
                    ),
                    SizedBox(height: 10),
                    Text('Exercises Added:'),
                    ...exercises.map((exercise) {
                      return ListTile(
                        title: Text(exercise['name']),
                        subtitle: Text(
                          'Muscle Group: ${exercise['muscleGroup']}, Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']} kg',
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text('Select Date: ${_formatDate(selectedDate)}'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (workoutNameController.text.isNotEmpty && exercises.isNotEmpty) {
                      final dateKey = _formatDate(selectedDate);
                      setState(() {
                        _workoutsByDate.putIfAbsent(dateKey, () => []).add({
                          'workoutName': workoutNameController.text,
                          'exercises': exercises,
                        });
                      });

                      Navigator.pop(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Workout name and at least one exercise must be added.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMealDialog() {
    final TextEditingController mealNameController = TextEditingController();
    final TextEditingController proteinController = TextEditingController();
    final TextEditingController carbsController = TextEditingController();
    final TextEditingController fatController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Meal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: mealNameController,
                  decoration: InputDecoration(labelText: 'Meal Name'),
                ),
                TextField(
                  controller: proteinController,
                  decoration: InputDecoration(labelText: 'Protein (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: carbsController,
                  decoration: InputDecoration(labelText: 'Carbs (g)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: fatController,
                  decoration: InputDecoration(labelText: 'Fat (g)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text('Select Date: ${_formatDate(selectedDate)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mealNameController.text.isNotEmpty &&
                    proteinController.text.isNotEmpty &&
                    carbsController.text.isNotEmpty &&
                    fatController.text.isNotEmpty) {
                  final dateKey = _formatDate(selectedDate);
                  setState(() {
                    _mealsByDate.putIfAbsent(dateKey, () => []).add({
                      'mealName': mealNameController.text,
                      'macros': {
                        'protein': double.tryParse(proteinController.text) ?? 0.0,
                        'carbs': double.tryParse(carbsController.text) ?? 0.0,
                        'fat': double.tryParse(fatController.text) ?? 0.0,
                      },
                    });
                  });

                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Heaviest PR Progress by Muscle Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedMuscleGroup,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMuscleGroup = newValue!;
                });
              },
              items: _muscleGroups.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: CustomPaint(
                painter: HeaviestPRGraphPainter(_generateHeaviestPRsByMuscleGroup(_selectedMuscleGroup)),
                child: Container(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ..._workoutsByDate.keys.map((dateKey) {
                    final totalMacros = _calculateTotalMacros(dateKey);
                    return ExpansionTile(
                      title: Text('Activities for $dateKey'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Total Macros - Protein: ${totalMacros['protein']}g, Carbs: ${totalMacros['carbs']}g, Fat: ${totalMacros['fat']}g',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_workoutsByDate[dateKey]?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Workouts',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...(_workoutsByDate[dateKey] ?? []).map((workout) {
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ExpansionTile(
                              title: Text(workout['workoutName']),
                              children: [
                                ...workout['exercises'].map<Widget>((exercise) {
                                  return ListTile(
                                    title: Text(exercise['name']),
                                    subtitle: Text(
                                      'Muscle Group: ${exercise['muscleGroup']}, Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']} kg',
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }).toList(),
                        if (_mealsByDate[dateKey]?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Meals',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ...(_mealsByDate[dateKey] ?? []).map((meal) {
                          final macros = meal['macros'];
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(meal['mealName']),
                              subtitle: Text(
                                'Protein: ${macros['protein']}g, Carbs: ${macros['carbs']}g, Fat: ${macros['fat']}g',
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddWorkoutDialog,
            child: Icon(Icons.fitness_center),
            tooltip: 'Add Workout',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showAddMealDialog,
            child: Icon(Icons.restaurant),
            tooltip: 'Add Meal',
          ),
        ],
      ),
    );
  }
}

class HeaviestPRGraphPainter extends CustomPainter {
  final List<double> dataPoints;

  HeaviestPRGraphPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final path = Path();
    final double xStep = size.width / (dataPoints.length - 1);
    final double maxY = dataPoints.reduce((a, b) => a > b ? a : b);
    final double yScale = maxY > 0 ? size.height / maxY : 1.0;

    path.moveTo(0, size.height - dataPoints[0] * yScale);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * xStep;
      final y = size.height - dataPoints[i] * yScale;
      path.lineTo(x, y);

      // Draw a small circle at each point
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.red);

      // Draw the weight value at each point
      textPainter.text = TextSpan(
        text: '${dataPoints[i].toStringAsFixed(1)} kg',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, y - 20));
    }

    canvas.drawPath(path, paint);

    // Draw y-axis labels (weight)
    for (double y = 0; y <= maxY; y += maxY / 4) {
      final yPos = size.height - y * yScale;
      textPainter.text = TextSpan(
        text: '${y.toStringAsFixed(0)} kg',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, yPos - 6));
    }

    // Draw x-axis labels (days)
    for (int i = 0; i < dataPoints.length; i++) {
      final xPos = i * xStep;
      textPainter.text = TextSpan(
        text: 'Day ${i + 1}',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - 10, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

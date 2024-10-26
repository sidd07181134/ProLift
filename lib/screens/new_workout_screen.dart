import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class NewWorkoutScreen extends StatefulWidget {
  @override
  _NewWorkoutScreenState createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final TextEditingController _workoutNameController = TextEditingController();
  final List<Map<String, dynamic>> _exercises = [];

  void _addExercise() {
    final TextEditingController exerciseNameController = TextEditingController();
    final TextEditingController setsController = TextEditingController();
    final TextEditingController repsController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: exerciseNameController,
                  decoration: InputDecoration(labelText: 'Exercise Name'),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (exerciseNameController.text.isNotEmpty &&
                    setsController.text.isNotEmpty &&
                    repsController.text.isNotEmpty &&
                    weightController.text.isNotEmpty) {
                  setState(() {
                    _exercises.add({
                      'name': exerciseNameController.text,
                      'sets': int.tryParse(setsController.text) ?? 0,
                      'reps': int.tryParse(repsController.text) ?? 0,
                      'weight': double.tryParse(weightController.text) ?? 0.0,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveWorkout() async {
    if (_workoutNameController.text.isNotEmpty && _exercises.isNotEmpty) {
      Workout newWorkout = Workout(
        name: _workoutNameController.text,
        exercises: _exercises,
      );

      await WorkoutService().addWorkout(newWorkout);

      // Navigate back to the dashboard after saving the workout
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _workoutNameController,
              decoration: InputDecoration(labelText: 'Workout Name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addExercise,
              child: Text('Add Exercise'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(exercise['name']),
                      subtitle: Text(
                        'Sets: ${exercise['sets']}, Reps: ${exercise['reps']}, Weight: ${exercise['weight']} kg',
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveWorkout,
              child: Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}

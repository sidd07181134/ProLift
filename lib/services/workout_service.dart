import 'package:sqflite/sqflite.dart';
import '../models/workout.dart';
import 'database_service.dart';

class WorkoutService {
  Future<void> addWorkout(Workout workout) async {
    final db = await DatabaseService().database;

    // Insert workout information and get its ID
    int workoutId = await db.insert('workouts', {'name': workout.name});

    // Insert each exercise linked to this workout
    for (var exercise in workout.exercises) {
      await db.insert('exercises', {
        'workout_id': workoutId,
        'name': exercise['name'],
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'weight': exercise['weight'],
      });
    }
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> workoutMaps = await db.query('workouts');

    List<Workout> workouts = [];
    for (var workoutMap in workoutMaps) {
      final List<Map<String, dynamic>> exerciseMaps = await db.query(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [workoutMap['id']],
      );
      List<Map<String, dynamic>> exercises = exerciseMaps.map((exerciseMap) {
        return {
          'name': exerciseMap['name'],
          'sets': exerciseMap['sets'],
          'reps': exerciseMap['reps'],
          'weight': exerciseMap['weight'],
        };
      }).toList();

      workouts.add(Workout(name: workoutMap['name'], exercises: exercises));
    }

    return workouts;
  }
}

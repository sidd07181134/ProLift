class Workout {
  final String name;
  final List<Map<String, dynamic>> exercises;

  Workout({required this.name, required this.exercises});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((exercise) => {
        'name': exercise['name'],
        'sets': exercise['sets'],
        'reps': exercise['reps'],
        'weight': exercise['weight'],
      }).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> exercises = List<Map<String, dynamic>>.from(map['exercises']);
    return Workout(
      name: map['name'],
      exercises: exercises,
    );
  }
}

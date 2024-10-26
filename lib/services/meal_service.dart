import 'package:sqflite/sqflite.dart';
import '../models/meals.dart';
import 'database_service.dart';

class MealService {
  Future<void> addMeal(Meal meal) async {
    final db = await DatabaseService().database;
    try {
      await db.insert(
        'meals',
        {
          'name': meal.name,
          'protein': meal.protein,
          'carbs': meal.carbs,
          'fat': meal.fat,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      print("Error saving meal: $error");
      throw Exception('Failed to save meal');
    }
  }

  Future<List<Meal>> getMeals() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> mealMaps = await db.query('meals');

    return List.generate(mealMaps.length, (i) {
      return Meal(
        name: mealMaps[i]['name'],
        protein: mealMaps[i]['protein'],
        carbs: mealMaps[i]['carbs'],
        fat: mealMaps[i]['fat'],
      );
    });
  }

  Future<Map<String, double>> getTotalMacros() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> mealMaps = await db.query('meals');

    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (var mealMap in mealMaps) {
      totalProtein += mealMap['protein'];
      totalCarbs += mealMap['carbs'];
      totalFat += mealMap['fat'];
    }

    return {
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
}

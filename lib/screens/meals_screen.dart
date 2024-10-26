import 'package:flutter/material.dart';
import '../models/meals.dart';
import '../services/meal_service.dart';
import '../widgets/meal_card.dart';

class MealsScreen extends StatefulWidget {
  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    List<Meal> meals = await MealService().getMeals();
    setState(() {
      _meals = meals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meals')),
      body: Column(
        children: [
          Expanded(
            child: _meals.isEmpty
                ? Center(child: Text('No meals added yet.'))
                : ListView.builder(
                    itemCount: _meals.length,
                    itemBuilder: (context, index) {
                      final meal = _meals[index];
                      return MealCard(
                        meal: meal,
                        onTap: () {
                          // Placeholder for meal details or editing
                        },
                      );
                    },
                  ),
          ),
          ElevatedButton(
            onPressed: () {
              // Placeholder for adding a new meal
            },
            child: Text('Add New Meal'),
          ),
        ],
      ),
    );
  }
}

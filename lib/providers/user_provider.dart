import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    int? age = prefs.getInt('age');
    double? weight = prefs.getDouble('weight');

    if (name != null && age != null && weight != null) {
      _user = User(name: name, age: age, weight: weight);
      notifyListeners();
    }
  }

  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name);
    await prefs.setInt('age', user.age);
    await prefs.setDouble('weight', user.weight);
    _user = user;
    notifyListeners();
  }
}

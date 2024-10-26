import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    int? age = prefs.getInt('age');
    double? weight = prefs.getDouble('weight');

    if (name != null && age != null && weight != null) {
      return User(name: name, age: age, weight: weight);
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name);
    await prefs.setInt('age', user.age);
    await prefs.setDouble('weight', user.weight);
  }
}

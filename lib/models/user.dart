class User {
  final String name;
  final int age;
  final double weight;

  User({required this.name, required this.age, required this.weight});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      age: map['age'],
      weight: map['weight'],
    );
  }
}

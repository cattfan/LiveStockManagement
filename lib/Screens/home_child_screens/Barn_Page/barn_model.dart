import 'package:firebase_database/firebase_database.dart';

class Barn {
  final String? id; // Key từ Firebase
  final String name;
  final int capacity;
  final int used;
  final String temp;
  final String humidity;

  Barn({
    this.id,
    required this.name,
    required this.capacity,
    required this.used,
    required this.temp,
    required this.humidity,
  });

  // Factory để tạo đối tượng Barn từ DataSnapshot của Firebase
  factory Barn.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    return Barn(
      id: snapshot.key,
      name: value['name'] ?? '',
      capacity: (value['capacity'] ?? 0) as int,
      used: (value['used'] ?? 0) as int,
      temp: value['temp'] ?? '',
      humidity: value['humidity'] ?? '',
    );
  }

  // Chuyển đổi đối tượng Barn thành Map để lưu lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'used': used,
      'temp': temp,
      'humidity': humidity,
    };
  }
}
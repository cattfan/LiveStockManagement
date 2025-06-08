import 'package:firebase_database/firebase_database.dart';

class Livestock {
  final String? id; // Sẽ là key từ Firebase
  final String ten;  // VD: Bò sữa
  final String chuong; // VD: A1
  final int soLuong;
  final String thucAn;

  Livestock({
    this.id,
    required this.ten,
    required this.chuong,
    required this.soLuong,
    required this.thucAn,
  });

  // Chuyển đổi từ DataSnapshot của Firebase thành đối tượng Livestock
  factory Livestock.fromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value as Map<dynamic, dynamic>;
    return Livestock(
      id: snapshot.key,
      ten: value['ten'] ?? '',
      chuong: value['chuong'] ?? '',
      soLuong: (value['soLuong'] ?? 0) as int,
      thucAn: value['thucAn'] ?? '',
    );
  }

  // Chuyển đổi đối tượng Livestock thành Map để lưu lên Firebase
  Map<String, dynamic> toJson() {
    return {
      'ten': ten,
      'chuong': chuong,
      'soLuong': soLuong,
      'thucAn': thucAn,
    };
  }
}

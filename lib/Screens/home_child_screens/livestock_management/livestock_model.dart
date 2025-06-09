import 'package:firebase_database/firebase_database.dart';

class Livestock {
  final String? id;
  final String ten;
  final String loai; // THÊM MỚI: Loại vật nuôi
  final String chuong;
  final int soLuong;
  final String thucAn;

  Livestock({
    this.id,
    required this.ten,
    required this.loai, // THÊM MỚI
    required this.chuong,
    required this.soLuong,
    required this.thucAn,
  });

  factory Livestock.fromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value as Map<dynamic, dynamic>;
    return Livestock(
      id: snapshot.key,
      ten: value['ten'] ?? '',
      loai: value['loai'] ?? 'Không xác định', // THÊM MỚI
      chuong: value['chuong'] ?? '',
      soLuong: (value['soLuong'] ?? 0) as int,
      thucAn: value['thucAn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ten': ten,
      'loai': loai, // THÊM MỚI
      'chuong': chuong,
      'soLuong': soLuong,
      'thucAn': thucAn,
    };
  }
}

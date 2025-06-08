import 'package:flutter/material.dart';


// Mô hình dữ liệu Livestock
class Livestock {
  final String name;
  final String imageUrl;
  final String quantity;
  final String vaccinationNote;
  final String food;
  final String cage;

  Livestock({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.vaccinationNote,
    required this.food,
    required this.cage,
  });
}

// Màn hình danh sách động vật
class LivestockGridScreen extends StatelessWidget {
  final List<Livestock> livestockList = [
    Livestock(
      name: 'Bò',
      imageUrl: 'https://plus.unsplash.com/premium_photo-1661962510497-9505129083fa?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      quantity: '12',
      vaccinationNote: 'Đã tiêm phòng tháng 5',
      food: 'Cỏ, cám',
      cage: 'Chuồng A1',
    ),
    Livestock(
      name: 'Heo',
      imageUrl: 'https://images.unsplash.com/photo-1567201080580-bfcc97dae346?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      quantity: '24',
      vaccinationNote: 'Tiêm phòng bệnh tai xanh',
      food: 'Cám tổng hợp',
      cage: 'Chuồng B2',
    ),
    Livestock(
      name: 'Gà',
      imageUrl: 'https://images.unsplash.com/photo-1644217147354-17d6e38108c6?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8Y2hpY2tlbnN8ZW58MHx8MHx8fDA%3D',
      quantity: '50',
      vaccinationNote: 'Chưa tiêm phòng',
      food: 'Thức ăn hỗn hợp',
      cage: 'Chuồng C',
    ),
    Livestock(
      name: 'Dê',
      imageUrl: 'https://plus.unsplash.com/premium_photo-1681882343875-0c709293d624?q=80&w=2028&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      quantity: '16',
      vaccinationNote: 'Tiêm vắc xin lở mồm long móng',
      food: 'Lá cây, rau củ',
      cage: 'Chuồng D4',
    ),
    Livestock(
        name: 'Vịt',
        imageUrl: 'https://images.unsplash.com/photo-1465153690352-10c1b29577f8?q=80&w=1915&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        quantity: '30',
        vaccinationNote: 'chưa tiêm phòng',
        food: 'Rau củ, cá',
        cage: 'Chuồng D1')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Toàn bộ vật nuôi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: livestockList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final animal = livestockList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LivestockDetailScreen(livestock: animal),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        animal.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    animal.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Màn hình chi tiết động vật
class LivestockDetailScreen extends StatelessWidget {
  final Livestock livestock;

  const LivestockDetailScreen({super.key, required this.livestock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          livestock.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  livestock.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Tên: ${livestock.name}", style: TextStyle(fontSize: 18)),
            Text("Số lượng: ${livestock.quantity}", style: TextStyle(fontSize: 18)),
            Text("Ghi chú tiêm chủng: ${livestock.vaccinationNote}", style: TextStyle(fontSize: 18)),
            Text("Thức ăn: ${livestock.food}", style: TextStyle(fontSize: 18)),
            Text("Chuồng: ${livestock.cage}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

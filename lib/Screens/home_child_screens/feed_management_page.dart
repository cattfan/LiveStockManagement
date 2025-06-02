import 'package:flutter/material.dart';

class FeedManagementPage extends StatelessWidget {
  const FeedManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),  // Màu mũi tên
        centerTitle: true,
        title: Text(
          'Quản lý Thức ăn',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionTitle('1. Feed Categories'),
            _buildCategoryFilter(),
            const SizedBox(height: 20),

            _buildSectionTitle('2. Feed Items'),
            _buildFeedItems(),
            const SizedBox(height: 20),

            _buildSectionTitle('3. Stock Levels'),
            _buildStockLevels(),
            const SizedBox(height: 20),

            _buildSectionTitle('4. Remind Stock'),
            _buildRemindStock(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
    );
  }

  Widget _buildCategoryFilter() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildFilterButton('All', true),
      _buildFilterButton('Grain', false),
      _buildFilterButton('Hay', false),
    ],
  );
}

Widget _buildFilterButton(String label, bool isSelected) {
  return ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: isSelected ? Colors.green[400] : Colors.grey[300],
      foregroundColor: isSelected ? Colors.white : Colors.black,
    ),
    child: Text(label),
  );
}


  Widget _buildFeedItems() {
    return Column(
      children: [
        _buildFeedItem('Corn Grain', 'https://images.unsplash.com/photo-1531171000775-75f0213ca8a0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y29ybnxlbnwwfHwwfHx8MA%3D%3D', '120 kg'),
        _buildFeedItem('Alfalfa Hay', 'https://plus.unsplash.com/premium_photo-1664359132441-4cab2cccb891?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aGF5fGVufDB8fDB8fHww', '40 kg'),
      ],
    );
  }

  Widget _buildFeedItem(String name, String imageUrl, String weight) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Weight: $weight'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () {},
      ),
    );
  }

  Widget _buildStockLevels() {
    return Column(
      children: [
        _buildStockBar('Corn Grain', 120, 200),
        _buildStockBar('Alfalfa Hay', 40, 50),
      ],
    );
  }

  Widget _buildStockBar(String name, int currentWeight, int capacity) {
    double ratio = currentWeight / capacity;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name ($currentWeight/$capacity kg)'),
          LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            backgroundColor: Colors.grey[300],
            color: ratio < 0.3 ? Colors.red : Colors.green,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindStock() {
    return Column(
      children: [
        _buildRemindItem('Alfalfa Hay', 2),
        _buildRemindItem('Corn Grain', 5),
      ],
    );
  }

  Widget _buildRemindItem(String name, int daysLeft) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Expires in $daysLeft days'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        onPressed: () {},
      ),
    );
  }
}

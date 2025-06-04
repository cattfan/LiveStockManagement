import 'package:flutter/material.dart';
import 'edit_barn_page.dart';

class AllBarnPage extends StatefulWidget {
  final List<Map<String, dynamic>> barns;

  const AllBarnPage({super.key, required this.barns});

  @override
  State<AllBarnPage> createState() => _AllBarnPageState();
}

class _AllBarnPageState extends State<AllBarnPage> {
  late List<Map<String, dynamic>> barns;

  @override
  void initState() {
    super.initState();
    barns = List<Map<String, dynamic>>.from(widget.barns); // tạo bản sao
  }

  void _editBarn(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBarnPage(barnData: barns[index]),
      ),
    );

    if (result != null) {
      setState(() {
        barns[index]['name'] = result['name'];
        barns[index]['max'] = result['capacity'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context, barns); // trả danh sách sau khi chỉnh sửa
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: const Text(
          'Tất cả chuồng trại',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: barns.length,
        itemBuilder: (context, index) {
          final barn = barns[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                barn['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Tối đa: ${barn['max']} - Đang dùng: ${barn['used']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _editBarn(index),
              ),
            ),
          );
        },
      ),
    );
  }
}

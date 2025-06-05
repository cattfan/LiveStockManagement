import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        fontFamily: 'Manrope',
        scaffoldBackgroundColor: const Color(0xFFf8fcf8),
      ),
      home: const NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();
  DateTime? _selectedDateTime;


  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color inputBgColor = Color(0xFFe7f3e7);
  static const Color buttonBgColor = Color(0xFF19e519);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // _reminderController.text = DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!); // Ví dụ định dạng
          _reminderController.text = _selectedDateTime.toString(); // Hoặc một định dạng khác bạn muốn
        });
      }
    }
  }


  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    color: pageBgColor,
                    padding: const EdgeInsets.only(top:4.0, right: 4.0, left: 4.0, bottom: 2.0),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 24),
                            onPressed: () {

                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          ),
                          Expanded(
                            child: Text(
                              'Thêm ghi chú',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 18, // text-lg
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.015 * 18, // tracking-[-0.015em]
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Để cân bằng với IconButton
                        ],
                      ),
                    ),
                  ),

                  // Title Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // px-4 py-3
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 16, // text-base
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Thêm tiêu đề',
                        hintStyle: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0), // rounded-xl
                          borderSide: BorderSide.none, // border-none
                        ),
                        contentPadding: const EdgeInsets.all(16.0), // p-4
                        isDense: true, // Giúp kiểm soát chiều cao tốt hơn
                      ),
                      minLines: 1,
                      maxLines: 1, // for input
                    ),
                  ),

                  // Notes Textarea
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // px-4 py-3
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 16, // text-base
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nội dung...',
                        hintStyle: const TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0), // rounded-xl
                          borderSide: BorderSide.none, // border-none
                        ),
                        contentPadding: const EdgeInsets.all(16.0), // p-4
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 5, // Tương đương min-h-36 (tùy vào font size và line height)
                      maxLines: null, // Cho phép mở rộng không giới hạn
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),

                  // Reminder Title
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0), // px-4 pb-2 pt-4
                    child: Text(
                      'Nhắc nhở',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 18, // text-lg
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015 * 18, // tracking-[-0.015em]
                      ),
                    ),
                  ),

                  // Reminder Input with Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // px-4 py-3
                    child: GestureDetector(
                      onTap: () => _selectDateTime(context),
                      child: AbsorbPointer( // Để TextField không nhận focus trực tiếp
                        child: TextField(
                          controller: _reminderController,
                          readOnly: true, // Để người dùng không nhập tay
                          style: const TextStyle(
                            color: primaryTextColor,
                            fontSize: 16, // text-base
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: InputDecoration(
                              hintText: 'Cài đặt ngày giờ',
                              hintStyle: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              filled: true,
                              fillColor: inputBgColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0), // rounded-xl
                                borderSide: BorderSide.none, // border-none
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(16, 16, 12, 16), // p-4, pr-2
                              isDense: true,
                              suffixIcon: Container(
                                // Styling cho phần icon giống HTML
                                decoration: const BoxDecoration(
                                  color: inputBgColor, // bg-[#e7f3e7]
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12.0), // rounded-r-xl
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                ),
                                padding: const EdgeInsets.only(right: 16.0), // pr-4
                                child: const Icon(
                                  Icons.calendar_today, // data-icon="Calendar"
                                  color: secondaryTextColor, // text-[#4e974e]
                                  size: 24,
                                ),
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Save Button and Spacer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // px-4 py-3
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryTextColor, // bg-[#19e519]
                    minimumSize: const Size(double.infinity, 40), // flex-1, h-10
                    padding: const EdgeInsets.symmetric(horizontal: 16.0), // px-4
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // rounded-full (h-10 / 2)
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Xử lý sự kiện lưu
                    final title = _titleController.text;
                    final notes = _notesController.text;
                    final reminder = _reminderController.text;
                    // ignore: avoid_print
                    print('Title: $title');
                    // ignore: avoid_print
                    print('Notes: $notes');
                    // ignore: avoid_print
                    print('Reminder: $reminder, Selected DateTime: $_selectedDateTime');
                  },
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      color: primaryTextColor, // text-[#0e1b0e]
                      fontSize: 14, // text-sm
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.015 * 14, // tracking-[0.015em]
                    ),
                  ),
                ),
              ),
              Container(
                height: 20, // h-5
                color: pageBgColor, // bg-[#f8fcf8]
              ),
            ],
          )
        ],
      ),
    );
  }
}
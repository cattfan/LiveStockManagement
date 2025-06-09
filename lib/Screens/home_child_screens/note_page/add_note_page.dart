// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:livestockmanagement/models/note_model.dart';

class NotesPage extends StatefulWidget {
  final Note? note;
  const NotesPage({super.key, this.note});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();
  DateTime? _selectedDateTime;

  final DatabaseReference _notesRef = FirebaseDatabase.instance.ref('notes');

  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color inputBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _notesController.text = widget.note!.content;
      if (widget.note!.reminderDate != null) {
        _selectedDateTime = widget.note!.reminderDate;
        _reminderController.text = _selectedDateTime.toString();
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? DateTime.now(),
        ),
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
          _reminderController.text = _selectedDateTime.toString();
        });
      }
    }
  }

  void _saveNote() {
    final String title = _titleController.text;
    final String notes = _notesController.text;
    final String? reminder = _selectedDateTime?.toIso8601String();

    if (title.isNotEmpty || notes.isNotEmpty) {
      final noteData = {
        'title': title,
        'content': notes,
        'reminderDate': reminder,
      };

      if (widget.note != null) {
        _notesRef
            .child(widget.note!.key!)
            .update(noteData)
            .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật ghi chú!')),
              );
              Navigator.pop(context);
            })
            .catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cập nhật thất bại: $error')),
              );
            });
      } else {
        _notesRef
            .push()
            .set(noteData)
            .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu ghi chú thành công!')),
              );
              Navigator.pop(context);
            })
            .catchError((error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $error')));
            });
      }
    }
  }

  void _deleteNote() {
    if (widget.note == null || widget.note!.key == null) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc muốn xóa ghi chú này?'),
            actions: [
              TextButton(
                child: const Text('Hủy'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  _notesRef
                      .child(widget.note!.key!)
                      .remove()
                      .then((_) {
                        Navigator.of(context).pop(); // close dialog
                        Navigator.of(context).pop(); // go back from edit page
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Xóa thất bại: $error')),
                        );
                      });
                },
              ),
            ],
          ),
    );
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
      backgroundColor: pageBgColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: pageBgColor,
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      right: 4.0,
                      left: 4.0,
                      bottom: 2.0,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: primaryTextColor,
                              size: 24,
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.note == null
                                  ? 'Thêm ghi chú'
                                  : 'Sửa ghi chú',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: primaryTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.015 * 18,
                              ),
                            ),
                          ),
                          if (widget.note != null)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: _deleteNote,
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 16,
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
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 16,
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
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      'Nhắc nhở',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015 * 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDateTime(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _reminderController,
                          readOnly: true,
                          style: const TextStyle(
                            color: primaryTextColor,
                            fontSize: 16,
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
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              16,
                              16,
                              12,
                              16,
                            ),
                            isDense: true,
                            suffixIcon: Container(
                              decoration: const BoxDecoration(
                                color: inputBgColor,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0),
                                ),
                              ),
                              padding: const EdgeInsets.only(right: 16.0),
                              child: const Icon(
                                Icons.calendar_today,
                                color: secondaryTextColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryTextColor,
                    minimumSize: const Size(double.infinity, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _saveNote,
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.015 * 14,
                    ),
                  ),
                ),
              ),
              Container(height: 20, color: pageBgColor),
            ],
          ),
        ],
      ),
    );
  }
}

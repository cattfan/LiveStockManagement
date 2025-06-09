import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:livestockmanagement/models/note_model.dart';
import 'package:livestockmanagement/Screens/home_child_screens/note_page/add_note_page.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  DatabaseReference? _notesRef;

  static const Color primaryTextColor = Color(0xFF0e1b0e);
  static const Color secondaryTextColor = Color(0xFF4e974e);
  static const Color cardBgColor = Color(0xFFe7f3e7);
  static const Color pageBgColor = Color(0xFFf8fcf8);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _notesRef = FirebaseDatabase.instance.ref('app_data/${user.uid}/ghi_chu');
    }
  }

  Future<void> _showDeleteConfirmationDialog(String noteKey) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                _notesRef?.child(noteKey).remove();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteItem(Note note) {
    return Card(
      color: cardBgColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryTextColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: primaryTextColor),
              ),
              if (note.reminderDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alarm,
                        color: secondaryTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'HH:mm dd/MM/yyyy',
                        ).format(note.reminderDate!),
                        style: const TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotesPage(note: note)),
          );
        },
        onLongPress: () {
          if (note.key != null) {
            _showDeleteConfirmationDialog(note.key!);
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 8.0,
        left: 4.0,
        right: 4.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: primaryTextColor),
        backgroundColor: pageBgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ghi chú',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body:
          _notesRef == null
              ? const Center(child: Text("Vui lòng đăng nhập để xem ghi chú."))
              : StreamBuilder(
                stream: _notesRef!.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return const Center(
                      child: Text(
                        'Chưa có ghi chú nào.',
                        style: TextStyle(color: primaryTextColor),
                      ),
                    );
                  }

                  final List<Note> todayNotes = [];
                  final List<Note> upcomingNotes = [];
                  final List<Note> pastNotes = [];
                  final now = DateTime.now();
                  final startOfToday = DateTime(now.year, now.month, now.day);

                  final notesMap = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );
                  notesMap.forEach((key, value) {
                    final noteData = Map<String, dynamic>.from(value);
                    final note = Note(
                      key: key,
                      title: noteData['title'] ?? 'Không có tiêu đề',
                      content: noteData['content'] ?? '',
                      reminderDate:
                          noteData['reminderDate'] != null
                              ? DateTime.tryParse(noteData['reminderDate'])
                              : null,
                    );

                    if (note.reminderDate != null) {
                      final reminderDay = DateTime(
                        note.reminderDate!.year,
                        note.reminderDate!.month,
                        note.reminderDate!.day,
                      );
                      if (reminderDay.isAtSameMomentAs(startOfToday)) {
                        todayNotes.add(note);
                      } else if (note.reminderDate!.isAfter(now)) {
                        upcomingNotes.add(note);
                      } else {
                        pastNotes.add(note);
                      }
                    } else {
                      pastNotes.add(note);
                    }
                  });

                  todayNotes.sort(
                    (a, b) => a.reminderDate!.compareTo(b.reminderDate!),
                  );
                  upcomingNotes.sort(
                    (a, b) => a.reminderDate!.compareTo(b.reminderDate!),
                  );
                  pastNotes.sort((a, b) {
                    if (a.reminderDate == null && b.reminderDate == null)
                      return 0;
                    if (a.reminderDate == null) return 1;
                    if (b.reminderDate == null) return -1;
                    return b.reminderDate!.compareTo(a.reminderDate!);
                  });

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todayNotes.isNotEmpty)
                          _buildSectionTitle('Ghi chú trong ngày'),
                        ...todayNotes.map((note) => _buildNoteItem(note)),
                        if (upcomingNotes.isNotEmpty)
                          _buildSectionTitle('Ghi chú sắp tới'),
                        ...upcomingNotes.map((note) => _buildNoteItem(note)),
                        if (pastNotes.isNotEmpty)
                          _buildSectionTitle('Ghi chú đã qua'),
                        ...pastNotes.map((note) => _buildNoteItem(note)),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotesPage()),
          );
        },
        backgroundColor: secondaryTextColor,
        elevation: 1,
        child: const Icon(Icons.add, color: pageBgColor),
      ),
    );
  }
}

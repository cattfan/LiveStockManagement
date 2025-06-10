class Note {
  final String? key;
  final String title;
  final String content;
  final DateTime? reminderDate;

  Note({
    this.key,
    required this.title,
    required this.content,
    this.reminderDate,
  });
}
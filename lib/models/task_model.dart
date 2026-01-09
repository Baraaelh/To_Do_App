class Task {
  int? id;
  String title;
  String description;
  int isComplete; // 0 للأصل، 1 للمكتمل

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isComplete = 0,
  });

  // تحويل الكائن إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isComplete': isComplete,
    };
  }

  // تحويل Map القادم من قاعدة البيانات إلى كائن Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isComplete: map['isComplete'],
    );
  }
}

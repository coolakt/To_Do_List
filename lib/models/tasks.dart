class Tasks {
  String task;
  DateTime time;

  Tasks({required this.task, required this.time});
  factory Tasks.fromString(String task) {
    return Tasks(task: task, time: DateTime.now());
  }
  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
        task: map['task'],
        time: DateTime.fromMillisecondsSinceEpoch(map['time']));
  }
  Map<String, dynamic> getMap() {
    return {'task': task, 'time': time.millisecondsSinceEpoch};
  }
}

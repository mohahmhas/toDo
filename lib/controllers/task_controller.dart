import 'package:get/get.dart';
import 'package:get_x_todo/db/db_helper.dart';
import 'package:get_x_todo/models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;
  Future<int> addTask({Task? task}) {
    return DBHelper.insert(task);
  }

  Future<void> getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void deletTasks(Task task) async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    await DBHelper.delet(task);
    getTasks();
  }

  void deletAllTasks() async {
    await DBHelper.deletAll();
    getTasks();
  }

  void markTaskCompleted(int id) async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    await DBHelper.update(id);
    getTasks();
  }
}

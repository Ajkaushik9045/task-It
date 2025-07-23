import 'dart:convert';

import 'package:frontend/core/constant/constant.dart';
import 'package:frontend/core/constant/util.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String hexColor,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constant.backendUrl}/task"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({
          'title': title,
          'description': description,
          'hexColor': hexColor,
          'dueAt': dueAt.toIso8601String(),
        }),
      );
      if (res.statusCode != 200) {
        final decoded = jsonDecode(res.body);
        throw (decoded['error']?.toString() ?? 'Unknown error occurred');
      }
      return TaskModel.fromJson(res.body);
    } catch (e) {
      try {
        final taskModel = TaskModel(
          id: const Uuid().v4(),
          uid: uid,
          title: title,
          description: description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueAt: dueAt,
          color: hexToRgb(hexColor),
          isSynced: 0,
        );
        await taskLocalRepository.insertTask(taskModel);
        return taskModel;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<TaskModel>> getTask({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constant.backendUrl}/task"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }
      final listOfTask = jsonDecode(res.body);

      List<TaskModel> taskList = [];

      for (var element in listOfTask) {
        taskList.add(TaskModel.fromMap(element));
      }
      await taskLocalRepository.insertTasks(taskList);

      return taskList;
    } catch (e) {
      final tasks = await taskLocalRepository.getTasks();
      if (tasks.isNotEmpty) {
        return tasks;
      }
      rethrow;
    }
  }

  Future<bool> syncTask({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constant.backendUrl}/task/sync"),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode(tasks),
      );
      if (res.statusCode != 200) {
        final decoded = jsonDecode(res.body);
        throw (decoded['error']?.toString() ?? 'Unknown error occurred');
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

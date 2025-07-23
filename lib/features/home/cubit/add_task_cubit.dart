import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/util.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/models/task_model.dart';

part 'add_task_state.dart';

class AddTaskCubit extends Cubit<AddTaskState> {
  AddTaskCubit() : super(AddTaskInitial());
  TaskRemoteRepository taskRemoteRepository = TaskRemoteRepository();
  TaskLocalRepository taskLocalRepository = TaskLocalRepository();

  Future<void> createNewTask({
    required String title,
    required String description,
    required Color hexColor,
    required String token,
    required DateTime dueAt,
    required String uid,
  }) async {
    try {
      final taskModel = await taskRemoteRepository.createTask(
        title: title,
        description: description,
        hexColor: rgbToHex(hexColor),
        token: token,
        dueAt: dueAt,
        uid: uid,
      );
      await taskLocalRepository.insertTask(taskModel);
      emit(AddTaskSuccess(taskModel: taskModel));
    } catch (e) {
      emit(AddTaskError(error: e.toString()));
    }
  }

  Future<void> getAllTask({required String token}) async {
    try {
      emit(AddTaskLoading());
      final tasks = await taskRemoteRepository.getTask(token: token);
      emit(GetTaskSuccess(tasks: tasks));
    } catch (e) {
      emit(AddTaskError(error: e.toString()));
    }
  }

  Future<void> syncTasks(String token) async {
    // get all unsynced tasks from our sqlite db
    final unsyncedTasks = await taskLocalRepository.getUnsyncedTasks();
    if (unsyncedTasks.isEmpty) {
      return;
    }

    // talk to our postgresql db to add the new task
    final isSynced = await taskRemoteRepository.syncTask(
      token: token,
      tasks: unsyncedTasks,
    );
    // // change the tasks that were added to the db from 0 to 1
    if (isSynced) {
      print("synced done");
      for (final task in unsyncedTasks) {
        taskLocalRepository.updateRowValue(task.id, 1);
      }
    }
  }
}

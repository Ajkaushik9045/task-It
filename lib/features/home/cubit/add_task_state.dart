part of 'add_task_cubit.dart';

sealed class AddTaskState {
  const AddTaskState();
}

final class AddTaskInitial extends AddTaskState {}

final class AddTaskLoading extends AddTaskState {}

final class AddTaskError extends AddTaskState {
  final String error;

  AddTaskError({required this.error});
}

final class AddTaskSuccess extends AddTaskState {
  final TaskModel taskModel;

  const AddTaskSuccess({required this.taskModel});
}

final class GetTaskSuccess extends AddTaskState {
  final List<TaskModel> tasks;

  const GetTaskSuccess({required this.tasks});
}

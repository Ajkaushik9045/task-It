import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/util.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/repository/auth_remote.dart';
import 'package:frontend/features/auth/pages/sign_up.dart';
import 'package:frontend/features/home/cubit/add_task_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task.dart';
import 'package:frontend/features/home/widget/date_selector.dart';
import 'package:frontend/features/home/widget/task_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const HomePage());

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  final AuthRemote _authRemote = AuthRemote();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state as AuthLoggedIn;
    Connectivity().onConnectivityChanged.listen((data) async {
      if (data.contains(ConnectivityResult.wifi)) {
        await context.read<AddTaskCubit>().syncTasks(user.user.token);
      }
    });
    _fetchTasks();
  }

  void _fetchTasks() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      context.read<AddTaskCubit>().getAllTask(token: authState.user.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the user's name from AuthCubit
    String? userName;
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthLoggedIn) {
      userName = authState.user.name;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("TaskIt"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authRemote.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                  (route) => false,
                );
              }
            },
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(context, AddNewTask.route());
              _fetchTasks();
            },
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: BlocBuilder<AddTaskCubit, AddTaskState>(
        builder: (context, state) {
          if (state is AddTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AddTaskError) {
            return Center(child: Text(state.error));
          }
          if (state is GetTaskSuccess) {
            final tasks = state.tasks
                .where(
                  (elem) =>
                      DateFormat("d").format(elem.dueAt) ==
                          DateFormat("d").format(selectedDate) &&
                      selectedDate.month == elem.dueAt.month &&
                      selectedDate.year == elem.dueAt.year,
                )
                .toList();
            // print(tasks);

            return Column(
              children: [
                if (userName != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hi, $userName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                DateSelector(
                  selectedDate: selectedDate,
                  onTap: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              color: task.color,
                              headerText: task.title,
                              descriptionText: task.description,
                            ),
                          ),

                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: strengthnColor(task.color, 0.69),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              DateFormat.jm().format(task.dueAt),
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

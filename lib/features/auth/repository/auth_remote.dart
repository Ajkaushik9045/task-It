import "dart:convert";
import "package:frontend/core/constant/constant.dart";
import "package:frontend/core/service/sp_service.dart";
import "package:frontend/features/auth/repository/auth_local.dart";
import "package:frontend/models/user_model.dart";
import "package:http/http.dart" as http;

class AuthRemote {
  final spService = SpService();
  final authlocal = AuthLocal();
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constant.backendUrl}/auth/signUp'),
        headers: {
          'Content-Type': 'application/json', // ✅ Fixed here
        },
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['msg'];
      }

      // print('Raw response: ${res.body}'); // 🔍 Log it

      return UserModel.fromJson(res.body);
    } catch (e) {
      // print('Signup error: $e');
      throw e.toString();
    }
  }

  Future<UserModel> login({required email, required password}) async {
    try {
      final res = await http.post(
        Uri.parse('${Constant.backendUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json', // ✅ Fixed here
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'];
      }
      return UserModel.fromJson(res.body);
    } catch (e) {
      // print('Signup error: $e');
      throw e.toString();
    }
  }

  Future<UserModel?> getData() async {
    try {
      final token = await spService.getToken();
      if (token == null) {
        throw "No Token Found";
      }
      final res = await http.post(
        Uri.parse('${Constant.backendUrl}/auth/tokenIsValid'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userRes = await http.get(
        Uri.parse('${Constant.backendUrl}/auth'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (userRes.statusCode != 200) {
        throw jsonDecode(userRes.body)['msg'];
      }
      return UserModel.fromMap(jsonDecode(userRes.body));
    } catch (e) {
      print('Signup error: $e');

      final user = await authlocal.getUser();
      if (user != null) {
        print(user);
        return user;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear token from shared preferences
    await spService.clearToken();
    // Delete user from local database
    await authlocal.deleteOldDb();
    // Delete all tasks from local task database
    // final taskLocalRepository = TaskLocalRepository();
    // await taskLocalRepository.clearTasks();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/service/sp_service.dart';
import 'package:frontend/features/auth/repository/auth_local.dart';
import 'package:frontend/features/auth/repository/auth_remote.dart';
import 'package:frontend/models/user_model.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authremote = AuthRemote();
  final authLocal = AuthLocal();
  final spService = SpService();

  void getData() async {
    try {
      emit(AuthLoading());
      final token = await spService.getToken();

      if (token == null || token.isEmpty) {
        // Try local user as fallback
        final localUser = await authLocal.getUser();
        if (localUser != null) {
          emit(AuthLoggedIn(user: localUser));
        } else {
          emit(AuthInitial());
        }
        return;
      }

      final userModel = await authremote.getData();
      if (userModel != null) {
        await authLocal.insertUser(userModel);
        emit(AuthLoggedIn(user: userModel));
      } else {
        // Try local user as fallback
        final localUser = await authLocal.getUser();
        if (localUser != null) {
          emit(AuthLoggedIn(user: localUser));
        } else {
          emit(AuthInitial());
        }
      }
    } catch (e) {
      // Try local user as fallback
      final localUser = await authLocal.getUser();
      if (localUser != null) {
        emit(AuthLoggedIn(user: localUser));
      } else {
        emit(AuthInitial());
      }
    }
  }

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authremote.signUp(name: name, email: email, password: password);
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString(), error: e.toString()));
      // print(e.toString());
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      final userModel = await authremote.login(
        email: email,
        password: password,
      );

      if (userModel.token.isNotEmpty) {
        await spService.setToken(userModel.token);
      }
      await authLocal.insertUser(userModel);
      emit(AuthLoggedIn(user: userModel));
    } catch (e) {
      emit(AuthError(e.toString(), error: e.toString()));
      // print(e.toString());
    }
  }
}

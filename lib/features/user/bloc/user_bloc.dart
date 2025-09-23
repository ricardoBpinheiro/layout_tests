import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoading()) {
    on<LoadUserData>(_onLoadUserData);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadUserData(
    LoadUserData event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      await Future.delayed(Duration(seconds: 1));
      emit(
        UserLoaded(
          userName: 'Usuário Teste',
          userEmail: 'usuario@teste.com',
          avatarUrl:
              'https://cdn-icons-png.flaticon.com/512/12225/12225881.png',
        ),
      );
    } catch (e) {
      emit(UserError('Erro ao carregar dados do usuário'));
    }
  }

  void _onLogoutUser(LogoutUser event, Emitter<UserState> emit) {
    emit(UserLoading());
  }
}

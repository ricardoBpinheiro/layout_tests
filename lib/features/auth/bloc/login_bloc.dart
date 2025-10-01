import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/auth/data/login_repository.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository _repository;

  LoginBloc({required LoginRepository repository})
    : _repository = repository,
      super(LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final isValid = _isEmailValid(event.email);
    emit(state.copyWith(email: event.email, isEmailValid: isValid));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final isValid = event.password.length >= 6;
    emit(state.copyWith(password: event.password, isPasswordValid: isValid));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!_isEmailValid(event.email) || event.password.length < 6) {
      emit(
        state.copyWith(
          isEmailValid: _isEmailValid(event.email),
          isPasswordValid: event.password.length >= 6,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final result = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

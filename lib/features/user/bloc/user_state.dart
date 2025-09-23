part of 'user_bloc.dart';

abstract class UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final String userName;
  final String userEmail;
  final String? avatarUrl;

  UserLoaded({required this.userName, required this.userEmail, this.avatarUrl});
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

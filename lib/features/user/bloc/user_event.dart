part of 'user_bloc.dart';

abstract class UserEvent {}

class LoadUserData extends UserEvent {}

class LogoutUser extends UserEvent {}
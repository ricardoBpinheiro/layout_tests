part of 'side_bar_bloc.dart';

abstract class SidebarEvent {}

class ToggleSidebar extends SidebarEvent {}

class SelectMenuItem extends SidebarEvent {
  final String menuItem;
  SelectMenuItem(this.menuItem);
}

class SelectCompany extends SidebarEvent {
  final String company;
  SelectCompany(this.company);
}

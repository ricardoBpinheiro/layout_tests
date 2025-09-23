part of 'side_bar_bloc.dart';

abstract class SidebarState {}
class SidebarInitial extends SidebarState {}
class SidebarExpanded extends SidebarState {
  final bool isExpanded;
  final String selectedItem;
  
  SidebarExpanded({required this.isExpanded, required this.selectedItem});
}
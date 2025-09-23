import 'package:flutter_bloc/flutter_bloc.dart';

part 'side_bar_event.dart';
part 'side_bar_state.dart';

class SidebarBloc extends Bloc<SidebarEvent, SidebarState> {
  SidebarBloc() : super(SidebarInitial()) {
    on<ToggleSidebar>(_onToggleSidebar);
    on<SelectMenuItem>(_onSelectMenuItem);
  }

  bool _isExpanded = true;
  String _selectedItem = 'Dashboard';

  void _onToggleSidebar(ToggleSidebar event, Emitter<SidebarState> emit) {
    _isExpanded = !_isExpanded;
    emit(SidebarExpanded(isExpanded: _isExpanded, selectedItem: _selectedItem));
  }

  void _onSelectMenuItem(SelectMenuItem event, Emitter<SidebarState> emit) {
    _selectedItem = event.menuItem;
    emit(SidebarExpanded(isExpanded: _isExpanded, selectedItem: _selectedItem));
  }
}

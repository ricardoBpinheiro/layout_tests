import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/core/layout/header.dart';
import 'package:layout_tests/core/layout/sidebar.dart';
import 'package:layout_tests/features/sidebar/bloc/side_bar_bloc.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    String pageTitle;

    switch (location) {
      case '/dashboard':
        pageTitle = 'Dashboard';
        break;
      case '/users':
        pageTitle = 'Gerenciar Usuários';
        break;
      case '/products':
        pageTitle = 'Produtos';
        break;
      case '/reports':
        pageTitle = 'Relatórios';
        break;
      case '/settings':
        pageTitle = 'Configurações';
        break;
      default:
        pageTitle = 'Dashboard';
    }

    return Scaffold(
      body: Row(
        children: [
          BlocBuilder<SidebarBloc, SidebarState>(
            builder: (context, state) {
              bool isExpanded = true;
              String selectedItem = _getSelectedItemFromRoute(location);
              String selectedCompany = 'Empresa A';

              if (state is SidebarExpanded) {
                isExpanded = state.isExpanded;
                selectedCompany = state.selectedCompany;
              }

              return ClipRect(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: isExpanded ? 250 : 70,
                  child: CustomSidebar(
                    isExpanded: isExpanded,
                    selectedItem: selectedItem,
                    currentRoute: location,
                    selectedCompany: selectedCompany,
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: Column(
              children: [
                CustomHeader(pageTitle: pageTitle),
                Expanded(
                  child: Container(padding: EdgeInsets.all(16), child: child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSelectedItemFromRoute(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/users':
        return 'Usuários';
      case '/products':
        return 'Produtos';
      case '/reports':
        return 'Relatórios';
      case '/settings':
        return 'Configurações';
      default:
        return 'Dashboard';
    }
  }
}

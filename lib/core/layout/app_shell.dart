import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/core/helpers/ui_helpers.dart';
import 'package:layout_tests/core/layout/header.dart';
import 'package:layout_tests/core/layout/sidebar.dart';
import 'package:layout_tests/features/sidebar/bloc/side_bar_bloc.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isMobileScreen = isMobile(context);
    String pageTitle = _getPageTitle(location);

    if (isMobileScreen) {
      final currentIndex = _mobileIndexFromRoute(location);

      return Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: Padding(padding: const EdgeInsets.all(16), child: child),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (idx) {
            switch (idx) {
              case 0:
                context.go('/templates');
                break;
              case 1:
                context.go('/inspections');
                break;
              case 2:
                context.go('/inspections');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Templates',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_sharp),
              label: 'Inspeções',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              label: 'Ações',
            ),
          ],
        ),
      );
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

  int _mobileIndexFromRoute(String route) {
    switch (route) {
      case '/actions':
        return 2;
      case '/inspections':
        return 1;
      case '/templates':
      default:
        return 0;
    }
  }

  String _getPageTitle(String location) {
    switch (location) {
      case '/dashboard':
        return 'Dashboard';
      case '/users':
        return 'Gerenciar Usuários';
      case '/products':
        return 'Produtos';
      case '/reports':
        return 'Relatórios';
      case '/settings':
        return 'Configurações';
      case '/templates':
        return 'Templates';
      case '/inspections':
        return 'Inspeções';
      case '/actions':
        return 'Ações';
      default:
        return 'Dashboard';
    }
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

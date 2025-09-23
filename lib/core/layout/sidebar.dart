import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/sidebar/bloc/side_bar_bloc.dart';

class CustomSidebar extends StatelessWidget {
  final bool isExpanded;
  final String selectedItem;
  final String currentRoute;

  const CustomSidebar({
    super.key,
    required this.isExpanded,
    required this.selectedItem,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'route': '/dashboard'},
      {'icon': Icons.people, 'title': 'Usuários', 'route': '/users'},
      {'icon': Icons.inventory, 'title': 'Produtos', 'route': '/products'},
      {'icon': Icons.analytics, 'title': 'Relatórios', 'route': '/reports'},
      {'icon': Icons.settings, 'title': 'Configurações', 'route': '/settings'},
    ];

    return Container(
      width: isExpanded ? 200 : 70,
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: isExpanded
                ? Row(
                    children: [
                      Icon(Icons.business, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Layout Tester',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(Icons.business, color: Colors.white, size: 30),
                  ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = currentRoute == item['route'];

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      context.go(item['route'] as String);
                    },
                    child: Container(
                      height: 48,
                      padding: EdgeInsets.symmetric(
                        horizontal: isExpanded ? 16 : 0,
                        vertical: 8,
                      ),
                      child: isExpanded
                          ? Row(
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  size: 22,
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Icon(
                                item['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                size: 22,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () =>
                    context.read<SidebarBloc>().add(ToggleSidebar()),
                icon: Icon(
                  isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

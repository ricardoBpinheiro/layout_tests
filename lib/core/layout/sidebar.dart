import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/core/helpers/ui_helpers.dart';
import 'package:layout_tests/features/sidebar/bloc/side_bar_bloc.dart';

class CustomSidebar extends StatelessWidget {
  final bool isExpanded;
  final String selectedItem;
  final String currentRoute;
  final String? selectedCompany;

  const CustomSidebar({
    super.key,
    required this.isExpanded,
    required this.selectedItem,
    required this.currentRoute,
    this.selectedCompany,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = [
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'route': '/dashboard'},
      {'icon': Icons.people, 'title': 'Usuários', 'route': '/users'},
      {'icon': Icons.checklist_outlined, 'title': 'Ações', 'route': '/actions'},
      {'icon': Icons.inventory, 'title': 'Templates', 'route': '/templates'},
      {
        'icon': Icons.dashboard_customize_sharp,
        'title': 'Inspeções',
        'route': '/inspections',
      },
      {'icon': Icons.analytics, 'title': 'Relatórios', 'route': '/reports'},
      {'icon': Icons.settings, 'title': 'Configurações', 'route': '/settings'},
    ];

    final isMobileScreen = isMobile(context);
    final menuItems = isMobileScreen
        ? allItems.where((i) {
            final r = i['route'] as String;
            return r == '/templates' || r == '/inspections' || r == '/actions';
          }).toList()
        : allItems;

    final companies = ['Empresa A', 'Empresa B', 'Empresa C', 'Empresa D'];

    return Container(
      width: isExpanded ? 200 : 70,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header da sidebar
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
                      const Icon(Icons.business, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          'Layout Tester',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Icon(Icons.business, color: Colors.white, size: 30),
                  ),
          ),

          // Dropdown de empresas (opcionalmente ocultar em mobile)
          if (isExpanded && !isMobileScreen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: .2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCompany ?? 'Empresa A',
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 18,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: const Color(0xFF34495E),
                    items: companies.map<DropdownMenuItem<String>>((
                      String company,
                    ) {
                      return DropdownMenuItem<String>(
                        value: company,
                        child: Text(
                          company,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<SidebarBloc>().add(
                          SelectCompany(newValue),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),

          // Lista de menus (filtrada em mobile)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = currentRoute == item['route'];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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

          // Botão de expandir/retrair (opcional ocultar em mobile)
          if (!isMobileScreen)
            Container(
              padding: const EdgeInsets.all(8),
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

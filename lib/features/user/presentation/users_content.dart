import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/user/models/user_model.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  List<User> users = [
    User(
      id: '1',
      name: 'João Silva',
      email: 'joao@example.com',
      phone: '(11) 99999-9999',
      role: 'Administrador',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: '2',
      name: 'Maria Santos',
      email: 'maria@example.com',
      phone: '(11) 88888-8888',
      role: 'Editor',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    User(
      id: '3',
      name: 'Pedro Costa',
      email: 'pedro@example.com',
      phone: '(11) 77777-7777',
      role: 'Usuário',
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    User(
      id: '4',
      name: 'Ana Oliveira',
      email: 'ana@example.com',
      phone: '(11) 66666-6666',
      role: 'Editor',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  bool _sortAscending = true;
  int? _sortColumnIndex;
  bool _isLoading = false;
  String _searchQuery = '';

  List<User> get filteredUsers {
    if (_searchQuery.isEmpty) return users;
    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.role.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _sort<T>(
    Comparable<T> Function(User user) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      users.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  void _toggleUserStatus(User user) {
    setState(() {
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = user.copyWith(isActive: !user.isActive);
      }
    });
  }

  void _deleteUser(User user) {
    setState(() {
      users.removeWhere((u) => u.id == user.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuário ${user.name} excluído com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editUser(User user) {
    context.go('/users/edit/${user.id}');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e ações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Usuários',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/users/create'),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Novo Usuário'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filtros e busca
          Row(
            children: [
              // Busca
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Buscar usuários...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Filtro por status
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Todos',
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Ativos', child: Text('Ativos')),
                      DropdownMenuItem(
                        value: 'Inativos',
                        child: Text('Inativos'),
                      ),
                    ],
                    onChanged: (value) {
                      // Implementar filtro
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Botão de atualizar
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        _isLoading = false;
                      });
                    });
                  },
                  icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tabela de usuários
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildDataTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhum usuário cadastrado'
                : 'Nenhum usuário encontrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Comece criando seu primeiro usuário'
                : 'Tente ajustar os filtros de busca',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/users/create'),
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeiro Usuário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 24,
      minWidth: 800,
      dataRowHeight: 60,
      headingRowHeight: 50,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
      headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
      border: TableBorder.all(color: const Color(0xFFE5E7EB), width: 1),
      columns: [
        DataColumn2(
          label: const Text(
            'Usuário',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.L,
          onSort: (columnIndex, ascending) =>
              _sort<String>((user) => user.name, columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text(
            'Email',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text(
            'Telefone',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text(
            'Função',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) =>
              _sort<String>((user) => user.role, columnIndex, ascending),
        ),
        DataColumn2(
          label: const Text(
            'Status',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text(
            'Criado em',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) =>
              _sort<DateTime>((user) => user.createdAt, columnIndex, ascending),
        ),
        const DataColumn2(
          label: Text(
            'Ações',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          size: ColumnSize.S,
        ),
      ],
      rows: filteredUsers.map((user) {
        return DataRow2(
          cells: [
            // Usuário (com avatar)
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(
                      0xFF2563EB,
                    ).withValues(alpha: 0.1),
                    child: user.avatar != null
                        ? ClipOval(
                            child: Image.network(
                              user.avatar!,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '#${user.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Email
            DataCell(
              Text(user.email, style: TextStyle(color: Colors.blue[600])),
            ),

            // Telefone
            DataCell(Text(user.phone)),

            // Função
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.role,
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Status
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isActive ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: user.isActive ? Colors.green[700] : Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Data de criação
            DataCell(
              Text(
                _formatDate(user.createdAt),
                style: const TextStyle(fontSize: 13),
              ),
            ),

            // Ações
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () => _editUser(user),
                    tooltip: 'Editar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: user.isActive ? Colors.orange : Colors.green,
                    ),
                    onPressed: () => _toggleUserStatus(user),
                    tooltip: user.isActive ? 'Desativar' : 'Ativar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => _showDeleteDialog(user),
                    tooltip: 'Excluir',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Administrador':
        return Colors.purple;
      case 'Editor':
        return Colors.blue;
      case 'Usuário':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              const TextSpan(text: 'Tem certeza que deseja excluir o usuário '),
              TextSpan(
                text: user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nEsta ação não pode ser desfeita.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

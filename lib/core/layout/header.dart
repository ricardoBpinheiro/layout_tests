import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/notification/models/notification_item.dart';
import 'package:layout_tests/features/notification/widgets/notifications_modal.dart';
import 'package:layout_tests/features/user/bloc/user_bloc.dart';

// ignore: must_be_immutable
class CustomHeader extends StatelessWidget {
  final String pageTitle;

  const CustomHeader({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              pageTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),

            Spacer(),

            IconButton(
              onPressed: () {
                showNotificationsModal(context);
              },
              icon: Stack(
                children: [
                  Icon(Icons.notifications_outlined, color: Color(0xFF2C3E50)),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),

            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: state.avatarUrl != null
                            ? NetworkImage(state.avatarUrl!)
                            : null,
                        child: state.avatarUrl == null
                            ? Icon(Icons.person, size: 20)
                            : null,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.userName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            state.userEmail,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF2C3E50),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Perfil'),
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                context.go('/account');
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('Configurações'),
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                context.go('/settings');
                              },
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Sair'),
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                context.read<UserBloc>().add(LogoutUser());
                                context.go('/login');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                if (state is UserLoading) {
                  return CircularProgressIndicator(strokeWidth: 2);
                }

                return Text('Erro');
              },
            ),
          ],
        ),
      ),
    );
  }

  void showNotificationsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => NotificationsModal(),
    );
  }
}

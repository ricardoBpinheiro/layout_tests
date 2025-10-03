import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/app_injection.dart';
import 'package:layout_tests/app_router.dart';
import 'package:layout_tests/features/inspections/bloc/inspection_bloc.dart';
import 'package:layout_tests/features/inspections/bloc/template_bloc.dart';
import 'package:layout_tests/features/inspections/data/inspection_repository.dart';
import 'package:layout_tests/features/inspections/data/template_repository.dart';
import 'package:layout_tests/features/sidebar/bloc/side_bar_bloc.dart';
import 'package:layout_tests/features/user/bloc/user_bloc.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SidebarBloc()),
        BlocProvider(create: (context) => UserBloc()..add(LoadUserData())),
        BlocProvider<InspectionBloc>(
          create: (context) =>
              InspectionBloc(repository: getIt<InspectionRepository>()),
        ),
        BlocProvider<TemplateBloc>(
          create: (context) =>
              TemplateBloc(repository: getIt<TemplateRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Admin Dashboard',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Color(0xFF2C3E50),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF3498DB)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

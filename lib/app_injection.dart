import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:layout_tests/features/inspections/data/inspection_repository.dart';
import 'package:layout_tests/features/inspections/data/inspection_repository_impl.dart';
import 'package:layout_tests/features/inspections/data/template_repository.dart';
import 'package:layout_tests/features/inspections/data/template_repository_impl.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<InspectionRepository>(
    InspectionRepositoryImpl(dio: Dio(), baseUrl: ''),
  );

  getIt.registerSingleton<TemplateRepository>(
    TemplateRepositoryImpl(dio: Dio(), baseUrl: ''),
  );
}

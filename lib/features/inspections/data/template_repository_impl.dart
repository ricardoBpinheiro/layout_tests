import 'package:dio/dio.dart';
import 'package:layout_tests/features/inspections/data/mock_templates.dart';
import 'package:layout_tests/features/inspections/data/template_repository.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_template.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final Dio dio;
  final String baseUrl;

  TemplateRepositoryImpl({required this.dio, required this.baseUrl});

  @override
  Future<List<InspectionTemplate>> getTemplates() async {
    try {
      // final response = await dio.get('$baseUrl/templates');

      // if (response.statusCode == 200) {
      //   final List<dynamic> data = response.data['data'] ?? response.data;
      //   return data.map((json) => InspectionTemplate.fromJson(json)).toList();
      // } else {
      //   throw Exception('Falha ao carregar templates');
      // }

      await Future.delayed(const Duration(milliseconds: 500));
      return MockTemplates.getTemplates();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<InspectionTemplate> getTemplateById(String id) async {
    try {
      // final response = await dio.get('$baseUrl/templates/$id');

      // if (response.statusCode == 200) {
      //   return InspectionTemplate.fromJson(
      //     response.data['data'] ?? response.data,
      //   );
      // } else {
      //   throw Exception('Falha ao carregar template');
      // }

      await Future.delayed(const Duration(milliseconds: 300));
      return MockTemplates.getTemplates().firstWhere(
        (template) => template.id == id,
        orElse: () => throw Exception('Template não encontrado'),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tempo de conexão esgotado. Verifique sua internet.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Erro desconhecido';
        return Exception('Erro $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Requisição cancelada');
      case DioExceptionType.connectionError:
        return Exception('Erro de conexão. Verifique sua internet.');
      default:
        return Exception('Erro inesperado: ${error.message}');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:layout_tests/features/inspections/data/inspection_repository.dart';
import 'package:layout_tests/features/inspections/data/mock_inspections.dart';
import 'package:layout_tests/features/inspections/models/inspection.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  final Dio dio;
  final String baseUrl;

  InspectionRepositoryImpl({required this.dio, required this.baseUrl});

  @override
  Future<List<Inspection>> getInspections() async {
    try {
      // final response = await dio.get('$baseUrl/inspections');

      // if (response.statusCode == 200) {
      //   final List<dynamic> data = response.data['data'] ?? response.data;
      //   return data.map((json) => Inspection.fromJson(json)).toList();
      // } else {
      //   throw Exception('Falha ao carregar inspeções');
      // }
      await Future.delayed(const Duration(milliseconds: 800));
      return MockInspections.getInspections();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Inspection> getInspectionById(String id) async {
    try {
      // final response = await dio.get('$baseUrl/inspections/$id');

      // if (response.statusCode == 200) {
      //   return Inspection.fromJson(response.data['data'] ?? response.data);
      // } else {
      //   throw Exception('Falha ao carregar inspeção');
      // }

      await Future.delayed(const Duration(milliseconds: 300));
      return MockInspections.getInspections().firstWhere(
        (inspection) => inspection.id == id,
        orElse: () => throw Exception('Inspeção não encontrada'),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteInspection(String id) async {
    try {
      // final response = await dio.delete('$baseUrl/inspections/$id');

      // if (response.statusCode != 200 && response.statusCode != 204) {
      //   throw Exception('Falha ao excluir inspeção');
      // }
      await Future.delayed(const Duration(milliseconds: 500));
      // Simular exclusão bem-sucedida
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Inspection> duplicateInspection(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final original = MockInspections.getInspections().firstWhere(
      (inspection) => inspection.id == id,
      orElse: () => throw Exception('Inspeção não encontrada'),
    );

    // Criar cópia com novo ID
    return Inspection(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      templateName: '${original.templateName} (Cópia)',
      sector: original.sector,
      documentNumber: 'INS-2025-${DateTime.now().millisecondsSinceEpoch}',
      score: 0,
      startedAt: '02/10/2025',
      completedAt: null,
      status: 'Rascunho',
      completedItems: '0/${original.completedItems.split('/').last}',
      location: original.location,
      responsibleName: original.responsibleName,
      lastEditedBy: original.responsibleName,
      startedAtFull:
          '02/10/2025 ${DateTime.now().hour}:${DateTime.now().minute}',
      updatedAtFull:
          '02/10/2025 ${DateTime.now().hour}:${DateTime.now().minute}',
    );
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

// inspections/data/inspection_template_repository.dart
import 'package:dio/dio.dart';
import '../models/inspection_template.dart';

class InspectionTemplateRepository {
  final Dio _dio;
  InspectionTemplateRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<InspectionTemplate>> fetchTemplates({
    int page = 1,
    int pageSize = 20,
    String? query,
  }) async {
    final resp = await _dio.get(
      'https://sua-api.com/inspection-templates',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    final list = (resp.data['items'] as List?) ?? [];
    return list.map((e) => InspectionTemplate.fromJson(e)).toList();
  }

  Future<InspectionTemplate> getById(String id) async {
    final resp = await _dio.get('https://sua-api.com/inspection-templates/$id');
    return InspectionTemplate.fromJson(resp.data);
  }

  Future<InspectionTemplate> create(InspectionTemplate model) async {
    final resp = await _dio.post(
      'https://sua-api.com/inspection-templates',
      // data: model.toJson(),
    );
    return InspectionTemplate.fromJson(resp.data);
  }

  Future<InspectionTemplate> update(InspectionTemplate model) async {
    final resp = await _dio.put(
      'https://sua-api.com/inspection-templates/${model.id}',
      // data: model.toJson(),
    );
    return InspectionTemplate.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _dio.delete('https://sua-api.com/inspection-templates/$id');
  }

  Future<InspectionTemplate> duplicate(String id) async {
    final resp = await _dio.post(
      'https://sua-api.com/inspection-templates/$id/duplicate',
    );
    return InspectionTemplate.fromJson(resp.data);
  }

  Future<InspectionTemplate> publish(String id) async {
    final resp = await _dio.post(
      'https://sua-api.com/inspection-templates/$id/publish',
    );
    return InspectionTemplate.fromJson(resp.data);
  }
}

import 'dart:typed_data';

class FieldAttachment {
  final String name;
  final String? mimeType;

  final String? path; // Android/iOS/desktop
  final Uint8List? bytes; // Web (ou se preferir carregar em memória)
  final String? url; // Após upload (opcional)

  FieldAttachment({
    required this.name,
    this.mimeType,
    this.path,
    this.bytes,
    this.url,
  });

  bool get isImage {
    final id = (mimeType ?? name).toLowerCase();
    return id.startsWith('image/') ||
        id.endsWith('.png') ||
        id.endsWith('.jpg') ||
        id.endsWith('.jpeg') ||
        id.endsWith('.gif') ||
        id.endsWith('.webp');
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'mimeType': mimeType,
    'path': path,
    'url': url,
    'bytes':
        bytes, // cuidado ao serializar; para persistir, converta para base64
  };

  factory FieldAttachment.fromJson(Map<String, dynamic> j) => FieldAttachment(
    name: j['name'],
    mimeType: j['mimeType'],
    path: j['path'],
    url: j['url'],
    bytes: j['bytes'], // idem observação
  );
}

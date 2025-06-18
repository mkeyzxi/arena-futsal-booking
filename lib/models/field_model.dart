// lib/models/field_model.dart
import 'package:flutter/foundation.dart'; // Untuk @required jika versi Dart < 2.12

class Field {
  final String id;
  final String name;
  final String
      surfaceType; // Contoh: "Rumput Sintetis", "Karpet Vinyl", "Profesional"
  final double pricePerHour;
  final String description;
  final String imageUrl; // URL gambar lapangan
  final List<String>
      amenities; // Fasilitas tambahan, e.g., "Toilet", "Cafeteria"

  Field({
    required this.id,
    required this.name,
    required this.surfaceType,
    required this.pricePerHour,
    this.description = '',
    this.imageUrl =
        'assets/images/field_placeholder.png', // Placeholder default
    this.amenities = const [],
  });

  factory Field.fromMap(Map<String, dynamic> data, String id) {
    return Field(
      id: id,
      name: data['name'] ?? 'Nama Lapangan',
      surfaceType: data['surfaceType'] ?? 'Tidak Diketahui',
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? 'assets/images/field_placeholder.png',
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surfaceType': surfaceType,
      'pricePerHour': pricePerHour,
      'description': description,
      'imageUrl': imageUrl,
      'amenities': amenities,
    };
  }
}

// Tambahkan copyWith method di Field model untuk kemudahan update
extension FieldCopyWith on Field {
  Field copyWith({
    String? id,
    String? name,
    String? surfaceType,
    double? pricePerHour,
    String? description,
    String? imageUrl,
    List<String>? amenities,
  }) {
    return Field(
      id: id ?? this.id,
      name: name ?? this.name,
      surfaceType: surfaceType ?? this.surfaceType,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      amenities: amenities ?? this.amenities,
    );
  }
}

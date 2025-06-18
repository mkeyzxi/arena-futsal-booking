// lib/screens/admin/admin_field_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/models/field_model.dart';
import 'package:futsal_booking_app/utils/app_colors.dart';

class AdminFieldManagementScreen extends StatefulWidget {
  const AdminFieldManagementScreen({super.key});

  @override
  State<AdminFieldManagementScreen> createState() =>
      _AdminFieldManagementScreenState();
}

class _AdminFieldManagementScreenState
    extends State<AdminFieldManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surfaceTypeController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  List<String> _amenities = [];
  String _newAmenity = '';

  Field? _editingField;

  @override
  void initState() {
    super.initState();
    // Refresh list fields when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FieldProvider>(context, listen: false).fetchFields();
    });
  }

  void _resetForm() {
    _nameController.clear();
    _surfaceTypeController.clear();
    _pricePerHourController.clear();
    _descriptionController.clear();
    _imageUrlController.clear();
    setState(() {
      _amenities = [];
      _newAmenity = '';
      _editingField = null;
    });
  }

  void _editField(Field field) {
    setState(() {
      _editingField = field;
      _nameController.text = field.name;
      _surfaceTypeController.text = field.surfaceType;
      _pricePerHourController.text = field.pricePerHour.toString();
      _descriptionController.text = field.description;
      _imageUrlController.text = field.imageUrl;
      _amenities = List.from(field.amenities);
    });
  }

  Future<void> _saveField() async {
    if (_formKey.currentState!.validate()) {
      final fieldProvider = Provider.of<FieldProvider>(context, listen: false);

      final newField = Field(
        id: _editingField?.id ?? '', // Akan di-generate jika baru
        name: _nameController.text,
        surfaceType: _surfaceTypeController.text,
        pricePerHour: double.parse(_pricePerHourController.text),
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : 'assets/images/field_placeholder.png',
        amenities: _amenities,
      );

      try {
        if (_editingField == null) {
          await fieldProvider.addField(newField);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lapangan berhasil ditambahkan!')),
          );
        } else {
          await fieldProvider.updateField(newField);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lapangan berhasil diperbarui!')),
          );
        }
        _resetForm();
        if (!mounted) return;
        Navigator.pop(context); // Tutup dialog
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan lapangan: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(String fieldId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lapangan?'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus lapangan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (!mounted) return;
        await Provider.of<FieldProvider>(context, listen: false)
            .deleteField(fieldId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lapangan berhasil dihapus!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus lapangan: $e')),
        );
      }
    }
  }

  void _showFieldFormDialog({Field? field}) {
    _resetForm();
    if (field != null) {
      _editField(field);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Gunakan StateBuilder atau StatefulBuilder untuk memperbarui UI dalam modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _editingField == null
                            ? 'Tambah Lapangan Baru'
                            : 'Edit Lapangan',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            labelText: 'Nama Lapangan',
                            prefixIcon: Icon(Icons.sports_soccer)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lapangan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _surfaceTypeController,
                        decoration: const InputDecoration(
                            labelText: 'Tipe Permukaan (e.g. Rumput Sintetis)',
                            prefixIcon: Icon(Icons.grass)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tipe permukaan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _pricePerHourController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Harga per Jam',
                            prefixIcon: Icon(Icons.attach_money)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Harga harus angka positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            prefixIcon: Icon(Icons.description)),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                            labelText: 'URL Gambar (Opsional)',
                            prefixIcon: Icon(Icons.image)),
                      ),
                      const SizedBox(height: 15),
                      const Text('Fasilitas:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: _amenities
                            .map((amenity) => Chip(
                                  label: Text(amenity),
                                  onDeleted: () {
                                    setModalState(() {
                                      // Gunakan setModalState di sini
                                      _amenities.remove(amenity);
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: TextEditingController(
                                  text:
                                      _newAmenity), // Gunakan controller sementara
                              onChanged: (value) {
                                _newAmenity = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Tambah Fasilitas',
                                prefixIcon: Icon(Icons.add_box),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: AppColors.primaryColor, size: 30),
                            onPressed: () {
                              if (_newAmenity.isNotEmpty &&
                                  !_amenities.contains(_newAmenity)) {
                                setModalState(() {
                                  // Gunakan setModalState di sini
                                  _amenities.add(_newAmenity);
                                  _newAmenity = ''; // Reset input field
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Consumer<FieldProvider>(
                        builder: (context, fieldProvider, child) {
                          return ElevatedButton(
                            onPressed:
                                fieldProvider.isLoading ? null : _saveField,
                            child: fieldProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(_editingField == null
                                    ? 'Tambahkan Lapangan'
                                    : 'Perbarui Lapangan'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surfaceTypeController.dispose();
    _pricePerHourController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Lapangan'),
      ),
      body: Consumer<FieldProvider>(
        builder: (context, fieldProvider, child) {
          if (fieldProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fieldProvider.fields.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada lapangan yang terdaftar. Tambahkan sekarang!',
                style: TextStyle(fontSize: 16, color: AppColors.lightTextColor),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: fieldProvider.fields.length,
            itemBuilder: (context, index) {
              final field = fieldProvider.fields[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      field.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/field_placeholder.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    field.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(field.surfaceType),
                      Text('Rp ${field.pricePerHour.toStringAsFixed(0)}/jam'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: AppColors.primaryColor),
                        onPressed: () => _showFieldFormDialog(field: field),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: AppColors.errorColor),
                        onPressed: () => _confirmDelete(field.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFieldFormDialog(),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

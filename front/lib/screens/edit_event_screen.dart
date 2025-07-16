import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/api_service.dart';
import '../models/event_model.dart';
import 'home_screen.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() =>
      _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;

  bool _isLoading = false;
  File? _selectedImage; // New image picked by user

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.event.title,
    );
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _dateController = TextEditingController(
      text: widget.event.date,
    );
    _timeController = TextEditingController(
      text: widget.event.time,
    );
    _locationController = TextEditingController(
      text: widget.event.location,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': _dateController.text.trim(),
      'time': _timeController.text.trim(),
      'location': _locationController.text.trim(),
    };

    try {
      final success = await ApiService.updateEventWithImage(
        widget.event.eventId,
        updatedData,
        _selectedImage, // Pass new image if picked
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully!'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update event.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred while updating.',
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Title is required'
                            : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Date is required'
                            : null,
              ),
              const SizedBox(height: 12),

              // Time
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (HH:MM)',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Time is required'
                            : null,
              ),
              const SizedBox(height: 12),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Location is required'
                            : null,
              ),
              const SizedBox(height: 12),

              // Created By (read-only)
              TextFormField(
                initialValue: widget.event.createdBy,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Created By',
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Current or selected image preview
              (_selectedImage != null)
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                  : (widget.event.image != null &&
                      widget.event.image!.isNotEmpty)
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.event.image!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.event,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
              const SizedBox(height: 12),

              // Button to pick a new image
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Change Event Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _updateEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF4A90E2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                          : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

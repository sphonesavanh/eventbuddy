import 'package:flutter/material.dart';
import '../api/api_service.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailScreen> createState() =>
      _EventDetailScreenState();
}

class _EventDetailScreenState
    extends State<EventDetailScreen> {
  Map<String, dynamic>? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final data = await ApiService.getEventById(
        widget.eventId,
      );
      setState(() {
        _event = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading event detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_event?['title'] ?? 'Event Detail'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _event == null
              ? const Center(
                child: Text('Failed to load event.'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if ((_event!['image_url'] as String?)
                            ?.isNotEmpty ==
                        true)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        child: Image.network(
                          _event!['image_url'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _event!['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _event!['description'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(_event!['date'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(_event!['time'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 18),
                        const SizedBox(width: 6),
                        Text(_event!['location'] ?? ''),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

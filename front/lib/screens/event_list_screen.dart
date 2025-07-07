import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() =>
      _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await ApiService.getEvents(limit: 10);
      // Filter out events missing 'id'
      final safeEvents =
          events
              .where((e) => e['id'] != null)
              .cast<Map<String, dynamic>>()
              .toList();

      setState(() {
        _events = safeEvents;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching events: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load events.'),
        ),
      );
    }
  }

  void _openEventDetail(Map<String, dynamic> event) {
    final eventId = event['id'];
    if (eventId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => EventDetailScreen(
                eventId: eventId as int,
              ),
        ),
      );
    } else {
      debugPrint('Event is missing ID: $event');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event cannot be opened.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _events.isEmpty
              ? const Center(
                child: Text(
                  'No events found.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                      title: Text(
                        event['title'] ?? 'Untitled Event',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      subtitle: Text(
                        event['description'] ?? '',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () => _openEventDetail(event),
                    ),
                  );
                },
              ),
    );
  }
}

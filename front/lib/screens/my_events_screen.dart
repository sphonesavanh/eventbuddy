import 'package:eventbuddy_app/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() =>
      _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<dynamic> _mine = []; // ✅ Stores the user's events
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMine();
  }

  Future<void> _loadMine() async {
    try {
      final events = await ApiService.getEvents(
        // You can pass email or userId if your API needs it
      );
      setState(() {
        _mine = events; // ✅ Store fetched events into _mine
      });
    } catch (e) {
      // You might want to show an error message here
      debugPrint('Failed to load events: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _mine.isEmpty
                ? const Center(
                  child: Text(
                    'You have not created any events yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount:
                      _mine
                          .length, // ✅ Use _mine instead of events
                  itemBuilder: (context, index) {
                    final event =
                        _mine[index]; // ✅ Correct variable
                    return ListTile(
                      title: Text(event['title']),
                      subtitle: Text(event['date']),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {
                        final eventId = event['event_id'];
                        if (eventId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EventDetailScreen(
                                    eventId: eventId,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This event has no ID!',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
      ),
    );
  }
}

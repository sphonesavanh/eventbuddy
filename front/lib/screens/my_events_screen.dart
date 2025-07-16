import 'package:eventbuddy_app/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../models/event_model.dart';
import '../providers/user_provider.dart';
import '../widgets/event_card.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() =>
      _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Event> _myEvents = [];
  bool _loading = true;
  User? _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_currentUser == null) {
      // ✅ Access UserProvider safely here
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      _currentUser = userProvider.currentUser;

      if (_currentUser != null) {
        _loadMyEvents(_currentUser!);
      } else {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMyEvents(User user) async {
    try {
      final events = await ApiService.getEventsByUser(
        user.email,
      );
      setState(() {
        _myEvents = events;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load user events: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load your events.'),
          ),
        );
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _currentUser == null
              ? const Center(
                child: Text(
                  'You are not logged in.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
              : _myEvents.isEmpty
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
                padding: const EdgeInsets.all(16),
                itemCount: _myEvents.length,
                itemBuilder: (context, index) {
                  final event = _myEvents[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => EventDetailScreen(
                                eventId: event.eventId,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

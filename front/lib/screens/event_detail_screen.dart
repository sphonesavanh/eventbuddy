import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import '../models/event_model.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'edit_event_screen.dart';

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
  Event? _event;
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
      if (!mounted) return; // ✅ Avoid context after await
      setState(() {
        _event = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading event detail: $e');
      if (!mounted) return; // ✅ Avoid context after await
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load event details.'),
        ),
      );
    }
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text(
              'Are you sure you want to delete this event?',
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteEvent(
        widget.eventId,
      );
      if (!mounted) return; // ✅ Avoid context after await

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully.'),
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
            content: Text('Failed to delete event.'),
          ),
        );
      }
    }
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat(
        'MMM dd, yyyy',
      ).format(date); // e.g., Aug 31, 2025
    } catch (_) {
      return rawDate; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final currentUser = userProvider.currentUser;

    return Scaffold(
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _event == null
              ? const Center(
                child: Text('Failed to load event.'),
              )
              : CustomScrollView(
                slivers: [
                  // AppBar with Edit/Delete
                  SliverAppBar(
                    expandedHeight: 250,
                    pinned: true,
                    actions: [
                      if (currentUser != null &&
                          _event!.createdBy ==
                              currentUser.email) ...[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final updated =
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            EditEventScreen(
                                              event:
                                                  _event!,
                                            ),
                                  ),
                                );
                            if (updated == true) {
                              _loadEvent();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: _deleteEvent,
                        ),
                      ],
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(
                        left: 16,
                        bottom: 12,
                      ),
                      title: Text(
                        _event!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ✅ Show event image from backend
                          (_event!.image ?? '').isNotEmpty
                              ? Image.network(
                                _event!.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.event,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4A90E2),
                                  Color(0xFF007AFF),
                                ],
                                begin:
                                    Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Event Details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            (_event!.description).isNotEmpty
                                ? _event!.description
                                : 'No description provided.',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(_event!.date),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _event!.time,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.place,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _event!.location,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 20,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Created by: ${_event!.createdBy}',
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ✅ Add image below Created by
                          (_event!.image ?? '').isNotEmpty
                              ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                      8,
                                    ),
                                child: Image.network(
                                  _event!.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return Container(
                                      color:
                                          Colors.grey[300],
                                      height: 200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

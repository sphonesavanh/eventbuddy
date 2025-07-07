import 'package:eventbuddy_app/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';

class JoinedEventScreen extends StatefulWidget {
  const JoinedEventScreen({super.key});

  @override
  State<JoinedEventScreen> createState() =>
      _JoinedEventScreenState();
}

class _JoinedEventScreenState
    extends State<JoinedEventScreen> {
  List<dynamic> _joined = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchJoinedEvents();
  }

  Future<void> _fetchJoinedEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tickets = await ApiService.getUserTickets(
        /* pass email if needed */
      );
      setState(() {
        _joined = tickets;
      });
    } catch (e) {
      debugPrint('Error fetching joined events: $e');
      setState(() {
        _errorMessage =
            'Failed to load joined events. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchJoinedEvents,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(),
                  )
                  : _errorMessage != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchJoinedEvents,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : _joined.isEmpty
                  ? const Center(
                    child: Text(
                      'You havent joined any events yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                  : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    itemCount: _joined.length,
                    itemBuilder: (context, index) {
                      final ticket = _joined[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            ticket['event_title'] ??
                                'Unnamed Event',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          subtitle: Text(
                            'Ticket #: ${ticket['ticket_id']}',
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailScreen(
                                  eventId: ticket['event_id'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}

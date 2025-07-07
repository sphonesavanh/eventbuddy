class Ticket {
  final int ticketId;
  final int eventId;
  final String status;

  Ticket({
    required this.ticketId,
    required this.eventId,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'],
      eventId: json['event_id'],
      status: json['status'],
    );
  }
}

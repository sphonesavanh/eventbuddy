class Event {
  final int eventId;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String createdBy;
  final String? image;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.createdBy,
    this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      title: json['title'] ?? 'Untitled Event',
      description: json['description'] ?? 'No description',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? 'No location',
      createdBy: json['created_by'] ?? '',
      image: json['image'],
    );
  }
}

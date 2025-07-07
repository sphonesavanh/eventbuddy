class Event {
  final int eventId;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final String imageUrl;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: json['date'],
      time: json['time'],
      location: json['location'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}

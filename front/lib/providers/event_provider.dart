import 'package:flutter/material.dart';
import 'package:eventbuddy_app/models/event_model.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  void setEvents(List<Event> events) {
    _events = events;
    notifyListeners();
  }

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }
}

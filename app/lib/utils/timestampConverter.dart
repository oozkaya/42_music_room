import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp == null) return null;
    return timestamp is Timestamp
        ? timestamp?.toDate()
        : DateTime.parse(timestamp);
  }

  @override
  String toJson(DateTime date) => date?.toString();
}

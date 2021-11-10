library musicroom.models;

import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';
import 'package:latlong/latlong.dart';
import 'package:spotify/spotify.dart';
import 'package:uuid/uuid.dart';

import '../utils/latLngConverter.dart';
import '../utils/timestampConverter.dart';

part '_models.g.dart';

part 'event_model.dart';
part 'event_settings.dart';
part 'event_track.dart';
part 'collab_model.dart';
part 'type_search.dart';
part 'user_model.dart';
part 'session_model.dart';

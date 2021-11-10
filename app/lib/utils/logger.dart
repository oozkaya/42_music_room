import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CustomLogger {
  CustomLogger();

  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace stackTrace]) {
    Logger().v(message, error, stackTrace);
  }

  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace stackTrace]) {
    Logger().d(message, error, stackTrace);
  }

  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace stackTrace]) {
    Logger().i(message, error, stackTrace);
  }

  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace stackTrace]) {
    Logger().w(message, error, stackTrace);
  }

  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace stackTrace]) {
    if (error != null) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    } else {
      FirebaseCrashlytics.instance.recordError(message, stackTrace);
    }
    Logger().e(message, error, stackTrace);
  }

  /// Log a message at level [Level.wtf].
  void wtf(dynamic message, [dynamic error, StackTrace stackTrace]) {
    Logger().wtf(message, error, stackTrace);
  }
}

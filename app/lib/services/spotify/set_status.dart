// import 'package:logger/logger.dart';
import '../../utils/logger.dart';

void setStatus(String code, {String message = '', CustomLogger logger}) {
  var text = message.isEmpty ? '' : ': $message';
  var _logger = logger != null ? logger : CustomLogger();

  _logger.d('$code$text');
}

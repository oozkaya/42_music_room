class CantPlayOnDemandException implements Exception {
  String cause;
  CantPlayOnDemandException(this.cause);
}

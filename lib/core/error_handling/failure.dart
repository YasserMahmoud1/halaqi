class Failure {
  final String message;
  final int? code;

  Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  ServerFailure(super.message, {super.code});
}

class ConnectionFailure extends Failure {
  ConnectionFailure(super.message, {super.code});
}

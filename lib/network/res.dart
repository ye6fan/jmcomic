import 'package:flutter/cupertino.dart';

@immutable
class Res<T> {
  final T? data;
  final String? errorMessage;

  @override
  String toString() => data.toString();

  const Res(this.data, [this.errorMessage]);
}

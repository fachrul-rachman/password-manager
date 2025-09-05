import 'package:equatable/equatable.dart';
import '../models/password_model.dart';

abstract class PasswordsEvent extends Equatable {
  const PasswordsEvent();

  @override
  List<Object?> get props => [];
}

class PasswordsFetched extends PasswordsEvent {
  const PasswordsFetched();
}

class PasswordAdded extends PasswordsEvent {
  final PasswordModel item;
  const PasswordAdded(this.item);

  @override
  List<Object?> get props => [item];
}

class PasswordUpdated extends PasswordsEvent {
  final PasswordModel item;
  const PasswordUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

class PasswordDeleted extends PasswordsEvent {
  final String id;
  const PasswordDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

import 'package:equatable/equatable.dart';
import '../models/password_model.dart';

abstract class PasswordsState extends Equatable {
  const PasswordsState();

  @override
  List<Object?> get props => [];
}

class PasswordsInitial extends PasswordsState {
  const PasswordsInitial();
}

class PasswordsLoading extends PasswordsState {
  const PasswordsLoading();
}

class PasswordsLoaded extends PasswordsState {
  final List<PasswordModel> items;
  const PasswordsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class PasswordsFailure extends PasswordsState {
  final String message;
  const PasswordsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

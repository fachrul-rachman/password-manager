import 'package:flutter_bloc/flutter_bloc.dart';
import 'passwords_event.dart';
import 'passwords_state.dart';
import '../repositories/passwords_repository.dart';
import '../models/password_model.dart';

class PasswordsBloc extends Bloc<PasswordsEvent, PasswordsState> {
  final PasswordsRepository repository;

  PasswordsBloc({required this.repository}) : super(const PasswordsInitial()) {
    on<PasswordsFetched>(_onFetched);
    on<PasswordAdded>(_onAdded);
    on<PasswordUpdated>(_onUpdated);
    on<PasswordDeleted>(_onDeleted);
  }

  Future<void> _onFetched(
    PasswordsFetched event,
    Emitter<PasswordsState> emit,
  ) async {
    emit(const PasswordsLoading());
    try {
      final items = await repository.fetchAll();
      emit(PasswordsLoaded(items));
    } catch (e) {
      emit(PasswordsFailure(e.toString()));
    }
  }

  Future<void> _onAdded(
    PasswordAdded event,
    Emitter<PasswordsState> emit,
  ) async {
    // Optional: tampilkan loading singkat saat proses add
    final previous = state;
    if (previous is PasswordsLoaded) {
      emit(const PasswordsLoading());
    }

    try {
      final created = await repository.create(event.item);

      if (state is PasswordsLoaded) {
        // jika state sudah loaded (balik dari repository cepat)
        final current = (state as PasswordsLoaded).items;
        emit(PasswordsLoaded(List<PasswordModel>.from(current)..add(created)));
      } else if (previous is PasswordsLoaded) {
        // kalau sempat ke Loading, kembalikan data lama + item baru
        final updated = List<PasswordModel>.from(previous.items)..add(created);
        emit(PasswordsLoaded(updated));
      } else {
        // fallback: fetch ulang
        add(const PasswordsFetched());
      }
    } catch (e) {
      emit(PasswordsFailure(e.toString()));
      // kembalikan ke data sebelumnya kalau ada
      if (previous is PasswordsLoaded) emit(PasswordsLoaded(previous.items));
    }
  }

  Future<void> _onUpdated(
    PasswordUpdated event,
    Emitter<PasswordsState> emit,
  ) async {
    final current = state;
    if (current is! PasswordsLoaded) {
      // kalau belum ada list, fetch dulu
      add(const PasswordsFetched());
      return;
    }

    emit(const PasswordsLoading());
    try {
      final updated = await repository.update(event.item);
      final newList = current.items
          .map((e) => e.id == updated.id ? updated : e)
          .toList(growable: false);
      emit(PasswordsLoaded(newList));
    } catch (e) {
      emit(PasswordsFailure(e.toString()));
      // restore ke state sebelumnya
      emit(PasswordsLoaded(current.items));
    }
  }

  Future<void> _onDeleted(
    PasswordDeleted event,
    Emitter<PasswordsState> emit,
  ) async {
    final current = state;
    if (current is! PasswordsLoaded) {
      // kalau belum ada list, fetch dulu
      add(const PasswordsFetched());
      return;
    }

    // Optimistic update: hapus dulu dari UI
    final optimistic = current.items.where((e) => e.id != event.id).toList();
    emit(PasswordsLoaded(optimistic));

    try {
      await repository.delete(event.id);
      // sukses: state sudah diupdate optimistik, biarkan
    } catch (e) {
      // gagal: kembalikan list semula & tampilkan error
      emit(PasswordsFailure(e.toString()));
      emit(PasswordsLoaded(current.items));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/passwords_bloc.dart';
import '../../blocs/passwords_event.dart';
import '../../blocs/passwords_state.dart';
import '../../models/password_model.dart';
import '../widgets/password_tile.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import 'password_form_page.dart';

class PasswordsPage extends StatelessWidget {
  const PasswordsPage({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus item?'),
        content: const Text('Apakah kamu yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passwords')),
      body: BlocBuilder<PasswordsBloc, PasswordsState>(
        builder: (context, state) {
          if (state is PasswordsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PasswordsLoaded) {
            if (state.items.isEmpty) {
              return const EmptyView();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PasswordsBloc>().add(const PasswordsFetched());
              },
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context),
                    onDismissed: (_) {
                      context
                          .read<PasswordsBloc>()
                          .add(PasswordDeleted(item.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item dihapus')),
                      );
                    },
                    child: PasswordTile(
                      item: item,
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PasswordFormPage(existing: item),
                          ),
                        );
                        if (updated is PasswordModel) {
                          context
                              .read<PasswordsBloc>()
                              .add(PasswordUpdated(updated));
                        }
                      },
                    ),
                  );
                },
              ),
            );
          } else if (state is PasswordsFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<PasswordsBloc>().add(const PasswordsFetched()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PasswordFormPage()),
          );
          if (created is PasswordModel) {
            context.read<PasswordsBloc>().add(PasswordAdded(created));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

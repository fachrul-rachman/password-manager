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
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 40, color: theme.colorScheme.error),
              const SizedBox(height: 8),
              Text(
                'Hapus item?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah kamu yakin ingin menghapus item ini?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Ya, Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final parent = Theme.of(context);

    // ✅ PAKSA warna baru dengan ColorScheme.fromSeed agar gak "kalah" sama dynamic color/global theme.
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0062FF), // ganti seed di sini kalau mau
      brightness: parent.brightness,      // hormati light/dark sistem
    );

    final pageTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: parent.textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      dividerColor: scheme.outlineVariant,
    );

    return Theme(
      data: pageTheme,
      child: Container(
        decoration: BoxDecoration(
          // ✅ Gradasi lebih kontras supaya “kerasa” berubah
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: parent.brightness == Brightness.dark
                ? const [Color(0xFF0B1020), Color(0xFF11182B)]
                : const [Color(0xFFEFF3FF), Color(0xFFFDFBFF)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _ModernAppBar(theme: pageTheme),
          body: SafeArea(
            child: BlocBuilder<PasswordsBloc, PasswordsState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: switch (state) {
                    PasswordsLoading() => const _LoadingView(),
                    PasswordsLoaded(items: final items)
                    => items.isEmpty
                        ? const _Padded(child: EmptyView())
                        : RefreshIndicator.adaptive(
                      color: pageTheme.colorScheme.primary,
                      onRefresh: () async {
                        context
                            .read<PasswordsBloc>()
                            .add(const PasswordsFetched());
                      },
                      edgeOffset: 12,
                      child: ListView.separated(
                        padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _SwipeToDelete(
                            onConfirm: () => _confirmDelete(context),
                            onDelete: () {
                              context
                                  .read<PasswordsBloc>()
                                  .add(PasswordDeleted(item.id));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text('Item dihapus'),
                                ),
                              );
                            },
                            child: _ModernCard(
                              child: PasswordTile(
                                item: item,
                                onTap: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PasswordFormPage(
                                        existing: item,
                                      ),
                                    ),
                                  );
                                  if (updated is PasswordModel) {
                                    context
                                        .read<PasswordsBloc>()
                                        .add(PasswordUpdated(updated));
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    PasswordsFailure(message: final msg) => _Padded(
                      child: ErrorView(
                        message: msg,
                        onRetry: () => context
                            .read<PasswordsBloc>()
                            .add(const PasswordsFetched()),
                      ),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PasswordFormPage()),
              );
              if (created is PasswordModel) {
                context.read<PasswordsBloc>().add(PasswordAdded(created));
              }
            },
            label: const Text('Tambah'),
            icon: const Icon(Icons.add_rounded),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.endContained,
        ),
      ),
    );
  }
}

/* --------------------------- Widgets pendukung UI -------------------------- */

class _ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ModernAppBar({required this.theme});
  final ThemeData theme;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 68,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.85),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
      ),
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passwords',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Simpan & kelola akses dengan aman',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () =>
              context.read<PasswordsBloc>().add(const PasswordsFetched()),
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _ModernCard extends StatelessWidget {
  const _ModernCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.colorScheme.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }
}

class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({
    required this.child,
    required this.onConfirm,
    required this.onDelete,
  });

  final Widget child;
  final Future<bool> Function() onConfirm;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(child.hashCode.toString() + UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirm(),
      onDismissed: (_) => onDelete(),
      background: const _DeleteBackground(),
      child: child,
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.error.withOpacity(0.7), c.error],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hapus',
              style: TextStyle(color: c.onError, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            builder: (context, s, child) => Transform.scale(scale: s, child: child),
            child: Icon(Icons.delete_rounded, color: c.onError),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surface;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _ShimmerBlock(color: base),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  const _ShimmerBlock({required this.color});
  final Color color;

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [base.withOpacity(0.9), base.withOpacity(0.7), base.withOpacity(0.9)],
              stops: [0.0, (_c.value * 0.6).clamp(0.2, 0.8), 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }
}

class _Padded extends StatelessWidget {
  const _Padded({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 24), child: child);
  }
}

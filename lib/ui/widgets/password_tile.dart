import 'package:flutter/material.dart';
import '../../models/password_model.dart';

class PasswordTile extends StatelessWidget {
  final PasswordModel item;
  final VoidCallback? onTap;

  const PasswordTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: _Avatar(imageUrl: item.imageUrl, title: item.title),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        item.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: cs.onSurfaceVariant,
      ),
      // biar ripple-nya keliatan bagus di atas card custom kita
      iconColor: cs.onSurfaceVariant,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _Avatar({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initials = _initialsFrom(title);

    // Warna container fallback yang serasi dengan theme.
    final fallbackBg = cs.secondaryContainer;
    final fallbackFg = cs.onSecondaryContainer;

    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: _deterministicContainerColor(context, title) ?? fallbackBg,
        child: Text(
          initials,
          style: TextStyle(
            color: fallbackFg,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: cs.surfaceVariant.withOpacity(0.3),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          // indikator loading kecil & halus
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
              ),
            );
          },
          // fallback error: kembali ke inisial dengan warna theme
          errorBuilder: (_, __, ___) => Container(
            width: 44,
            height: 44,
            color: _deterministicContainerColor(context, title) ?? fallbackBg,
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: fallbackFg,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initialsFrom(String text) {
    if (text.trim().isEmpty) return '?';
    final parts = text.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    String second = '';
    if (parts.length > 1) {
      second = parts[1].characters.first;
    }
    final result = (first + second).toUpperCase();
    return result.length > 2 ? result.substring(0, 2) : result;
  }
}

/// Menghasilkan warna container yang konsisten per judul (biar avatar beda-beda),
/// tetap berada dalam nuansa ColorScheme saat ini.
///
/// Catatan: kalau mau simpel, kamu bisa return `null` untuk selalu pakai secondaryContainer.
Color? _deterministicContainerColor(BuildContext context, String seed) {
  if (seed.isEmpty) return null;

  // Hash sederhana dari string -> 0..360
  int hash = 0;
  for (final codeUnit in seed.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  final hue = (hash % 360).toDouble();

  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Saturation & lightness disetel supaya tetap “container-like”
  final hsl = HSLColor.fromAHSL(
    1.0,
    hue,
    isDark ? 0.45 : 0.55,
    isDark ? 0.40 : 0.80,
  );

  // Campur sedikit dengan surface supaya nyatu dengan theme
  final base = hsl.toColor();
  return Color.alphaBlend(base.withOpacity(0.85), cs.surface);
}

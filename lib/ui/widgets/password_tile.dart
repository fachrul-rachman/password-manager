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
    return ListTile(
      onTap: onTap,
      leading: _Avatar(imageUrl: item.imageUrl, title: item.title),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.email, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _Avatar({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final initials =
        (title.isNotEmpty ? title.trim()[0] : '?').toUpperCase();

    if (imageUrl.isEmpty) {
      return CircleAvatar(child: Text(initials));
    }

    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(child: Text(initials)),
        ),
      ),
    );
  }
}

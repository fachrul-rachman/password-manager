import 'package:flutter/material.dart';
import '../../models/password_model.dart';

class PasswordFormPage extends StatefulWidget {
  final PasswordModel? existing;

  const PasswordFormPage({super.key, this.existing});

  @override
  State<PasswordFormPage> createState() => _PasswordFormPageState();
}

class _PasswordFormPageState extends State<PasswordFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  String _derivedImageUrl = '';

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing?.title ?? '');
    _emailController =
        TextEditingController(text: widget.existing?.email ?? '');
    _passwordController =
        TextEditingController(text: widget.existing?.password ?? '');

    // set awal derived image url (edit mode atau kosong)
    _derivedImageUrl = _iconUrlFromTitle(widget.existing?.title ?? '');
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final newUrl = _iconUrlFromTitle(_titleController.text);
    if (newUrl != _derivedImageUrl) {
      setState(() {
        _derivedImageUrl = newUrl;
      });
    }
  }

String _iconUrlFromTitle(String title) {
  final slug = title.trim().toLowerCase();
  if (slug.isEmpty) return '';
  return 'https://icon.horse/icon/$slug.com';
}

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final item = PasswordModel(
        id: widget.existing?.id ?? '',
        title: _titleController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        imageUrl: _derivedImageUrl, // ← otomatis dari title
      );
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final initials = (_titleController.text.isNotEmpty
            ? _titleController.text.trim()[0]
            : '?')
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Password' : 'Add Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Preview logo realtime
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: _derivedImageUrl.isEmpty
                        ? Center(child: Text(initials, style: const TextStyle(fontSize: 20)))
                        : Image.network(
                            _derivedImageUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(initials, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Apps Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Apps Name required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Email / Username'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email required' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Password required' : null,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

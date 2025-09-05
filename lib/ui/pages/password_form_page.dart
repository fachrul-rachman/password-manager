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
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _emailController = TextEditingController(text: widget.existing?.email ?? '');
    _passwordController = TextEditingController(text: widget.existing?.password ?? '');

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
      setState(() => _derivedImageUrl = newUrl);
    }
  }

  String _iconUrlFromTitle(String title) {
    final slug = title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
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
        imageUrl: _derivedImageUrl, // tetap otomatis dari title
      );
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final initials = (_titleController.text.isNotEmpty
        ? _titleController.text.trim()[0]
        : '?')
        .toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Password' : 'Add Password',
              style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'Lengkapi detail di bawah',
              style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: t.brightness == Brightness.dark
                ? const [Color(0xFF0B1020), Color(0xFF11182B)]
                : const [Color(0xFFEFF3FF), Color(0xFFFDFBFF)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                Center(
                  child: _LogoPreview(
                    imageUrl: _derivedImageUrl,
                    initials: initials,
                    titleSeed: _titleController.text,
                  ),
                ),
                const SizedBox(height: 16),

                _LabeledField(
                  label: 'Apps Name',
                  child: TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      context,
                      hint: 'cth: Instagram, Gmail, Netflix',
                      prefixIcon: Icons.apps_rounded,
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Apps Name required' : null,
                  ),
                ),
                const SizedBox(height: 12),

                _LabeledField(
                  label: 'Email / Username',
                  child: TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username, AutofillHints.email],
                    decoration: _inputDecoration(
                      context,
                      hint: 'name@example.com',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Email required' : null,
                  ),
                ),
                const SizedBox(height: 12),

                _LabeledField(
                  label: 'Password',
                  child: StatefulBuilder(
                    builder: (context, setSB) {
                      final strength = _estimateStrength(_passwordController.text);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            decoration: _inputDecoration(
                              context,
                              hint: '••••••••',
                              prefixIcon: Icons.lock_rounded,
                              suffix: IconButton(
                                tooltip: _obscure ? 'Show' : 'Hide',
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded),
                              ),
                            ),
                            validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Password required' : null,
                            onChanged: (_) => setSB(() {}),
                          ),
                          const SizedBox(height: 8),
                          _StrengthBar(value: strength),
                          const SizedBox(height: 4),
                          Text(
                            _strengthLabel(strength),
                            style: t.textTheme.bodySmall?.copyWith(
                              color: _strengthColor(context, strength),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomActions(
        primaryLabel: isEditing ? 'Update' : 'Create',
        onPrimary: _submit,
        onSecondary: () => Navigator.pop(context),
      ),
    );
  }

  // ---------- UI helpers ----------

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String hint,
        required IconData prefixIcon,
        Widget? suffix,
      }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffix,
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.6),
      ),
    );
  }

  // Estimasi kekuatan password sederhana (0..1)
  double _estimateStrength(String p) {
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[a-z]').hasMatch(p)) score++;
    if (RegExp(r'\d').hasMatch(p)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) score++;
    return (score / 5).clamp(0, 1).toDouble();
  }

  String _strengthLabel(double v) {
    if (v < 0.34) return 'Weak';
    if (v < 0.67) return 'Fair';
    return 'Strong';
  }

  Color _strengthColor(BuildContext context, double v) {
    final cs = Theme.of(context).colorScheme;
    if (v < 0.34) return cs.error;
    if (v < 0.67) return cs.tertiary;
    return cs.primary;
  }
}

/* --------------------------- Widgets pendukung UI -------------------------- */

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({
    required this.imageUrl,
    required this.initials,
    required this.titleSeed,
  });

  final String imageUrl;
  final String initials;
  final String titleSeed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                blurRadius: 16, offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: cs.surfaceVariant.withOpacity(0.3),
            child: ClipOval(
              child: imageUrl.isEmpty
                  ? _FallbackInitials(initials: initials, seed: titleSeed)
                  : Image.network(
                imageUrl,
                width: 72, height: 72, fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 72, height: 72,
                    child: Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) =>
                    _FallbackInitials(initials: initials, seed: titleSeed),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          imageUrl.isEmpty ? '' : '',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FallbackInitials extends StatelessWidget {
  const _FallbackInitials({required this.initials, required this.seed});
  final String initials;
  final String seed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = _deterministicContainerColor(context, seed) ?? cs.secondaryContainer;
    final fg = cs.onSecondaryContainer;

    return Container(
      width: 72,
      height: 72,
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }

  Color? _deterministicContainerColor(BuildContext context, String seed) {
    if (seed.isEmpty) return null;
    int hash = 0;
    for (final cu in seed.codeUnits) {
      hash = (hash * 31 + cu) & 0x7fffffff;
    }
    final hue = (hash % 360).toDouble();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromAHSL(
      1.0,
      hue,
      isDark ? 0.45 : 0.55,
      isDark ? 0.40 : 0.80,
    );
    final base = hsl.toColor();
    return Color.alphaBlend(base.withOpacity(0.85), Theme.of(context).colorScheme.surface);
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          t.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = value < 0.34
        ? cs.error
        : value < 0.67
        ? cs.tertiary
        : cs.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: cs.surfaceVariant.withOpacity(0.6),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12, offset: const Offset(0, -4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSecondary,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onPrimary,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

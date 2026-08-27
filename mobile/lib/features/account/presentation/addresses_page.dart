import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/addresses.dart';

/// Saved addresses.
///
/// Two fields, both free text. Oman is addressed by description far more often
/// than by street number, and a form demanding a postcode makes people invent
/// one — which then reaches a driver who cannot use it.
class AddressesPage extends ConsumerStatefulWidget {
  const AddressesPage({super.key});

  @override
  ConsumerState<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends ConsumerState<AddressesPage> {
  final _label = TextEditingController();
  final _detail = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _label.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _save() {
    if (_detail.text.trim().isEmpty) return;
    ref.read(addressesProvider.notifier).add(_label.text, _detail.text);
    _label.clear();
    _detail.clear();
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final addresses = ref.watch(addressesProvider);

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go('/profile/settings'),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Text(l.addressesTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.lg,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll([
            if (addresses.isEmpty && !_adding)
              Padding(
                padding: const EdgeInsets.only(top: NamatSpace.section),
                child: NamatEmptyState(
                  illustration: const NamatIcon(
                    NamatIcons.location,
                    size: 48,
                    color: NamatColors.inkSoft,
                  ),
                  title: l.noAddresses,
                  action: FilledButton(
                    onPressed: () => setState(() => _adding = true),
                    child: Text(l.addAddress),
                  ),
                ),
              )
            else ...[
              for (final a in addresses)
                Padding(
                  padding: const EdgeInsets.only(bottom: NamatSpace.sm),
                  child: NamatCard(
                    padding: const EdgeInsets.all(NamatSpace.lg),
                    child: Row(
                      children: [
                        const NamatIcon(
                          NamatIcons.location,
                          size: 19,
                          color: NamatColors.inkSoft,
                        ),
                        const SizedBox(width: NamatSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (a.label.isNotEmpty) ...[
                                Text(a.label, style: text.bodyMedium),
                                const SizedBox(height: 2),
                              ],
                              Text(a.detail, style: text.labelSmall),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.deleteAddress,
                          onPressed: () => ref
                              .read(addressesProvider.notifier)
                              .remove(a.id),
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: NamatColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_adding) ...[
                const SizedBox(height: NamatSpace.md),
                TextField(
                  controller: _label,
                  decoration: InputDecoration(
                    labelText: l.addressLabel,
                    hintText: l.addressLabelHint,
                  ),
                ),
                const SizedBox(height: NamatSpace.md),
                TextField(
                  controller: _detail,
                  autofocus: true,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l.addressDetail,
                    hintText: l.addressHint,
                  ),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: NamatSpace.md),
                FilledButton(
                  onPressed: _save,
                  child: Text(l.saveAddress),
                ),
              ] else ...[
                const SizedBox(height: NamatSpace.md),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _adding = true),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l.addAddress),
                ),
              ],
            ],
          ]),
        ),
      ),
    );
  }
}

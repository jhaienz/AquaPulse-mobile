import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enclosure.dart';
import '../models/species.dart';
import '../repositories/repositories.dart';
import '../theme.dart';

/// Bottom-sheet form to register a new enclosure (UI: "Add a Pond").
/// The first mutating path: writes through EnclosureRepository.add() and
/// invalidates the enclosures list so Map/History pick it up.
class AddPondSheet extends ConsumerStatefulWidget {
  const AddPondSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const AddPondSheet(),
      );

  @override
  ConsumerState<AddPondSheet> createState() => _AddPondSheetState();
}

class _AddPondSheetState extends ConsumerState<AddPondSheet> {
  final _name = TextEditingController();
  final _size = TextEditingController(text: '0.00');
  final _gps = TextEditingController(text: '14.5595° N, 120.9842° E');
  final _notes = TextEditingController();
  Species? _species;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _size.dispose();
    _gps.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (_species == null) {
      setState(() => _error = 'Pick a species');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    final repo = ref.read(enclosureRepositoryProvider);
    final count = (await repo.all()).length;
    final (lat, lng) = _parseGps(_gps.text);
    await repo.add(Enclosure(
      id: 'P-${count + 1}',
      name: _name.text.trim(),
      species: _species!,
      sizeHectares: double.tryParse(_size.text.trim()) ?? 0,
      latitude: lat,
      longitude: lng,
      notes: _notes.text.trim(),
    ));
    ref.invalidate(enclosuresProvider);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${_name.text.trim()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Add a Pond', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Register a new pond to your farm', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            _field(controller: _name, hint: 'e.g. Pond 7 — North Basin'),
            const SizedBox(height: 16),
            _sectionLabel('SPECIES', required: true),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in Species.values)
                _SpeciesChip(
                  label: s.label,
                  selected: _species == s,
                  onTap: () => setState(() => _species = s),
                ),
            ]),
            const SizedBox(height: 16),
            _sectionLabel('SIZE (HECTARES)'),
            const SizedBox(height: 8),
            _field(controller: _size, keyboardType: TextInputType.number, prefixIcon: Icons.straighten),
            const SizedBox(height: 16),
            _sectionLabel('LOCATION / GPS COORDINATES'),
            const SizedBox(height: 8),
            _field(controller: _gps, prefixIcon: Icons.location_on_outlined),
            const SizedBox(height: 16),
            _sectionLabel('NOTES'),
            const SizedBox(height: 8),
            _field(controller: _notes, hint: 'Water source, access notes, special conditions...', maxLines: 3),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.link, size: 16, color: AppColors.accent),
                SizedBox(width: 8),
                Expanded(child: Text('Sensors can be linked to this pond after creation via the Mesh screen.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ]),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.critical, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.add, size: 18),
                label: Text(_submitting ? 'Adding…' : 'Add Pond to Farm', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {bool required = false}) => Row(children: [
        Text(text, style: const TextStyle(fontSize: 12, letterSpacing: 0.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        if (required) const Text(' *', style: TextStyle(color: AppColors.critical)),
      ]);

  Widget _field({
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

/// Parse "14.5595° N, 120.9842° E" loosely; fall back to Manila-ish defaults.
(double, double) _parseGps(String s) {
  final nums = RegExp(r'-?\d+\.?\d*').allMatches(s).map((m) => double.parse(m.group(0)!)).toList();
  final lat = nums.isNotEmpty ? nums[0] : 14.5595;
  final lng = nums.length > 1 ? nums[1] : 120.9842;
  return (lat, lng);
}

class _SpeciesChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SpeciesChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}

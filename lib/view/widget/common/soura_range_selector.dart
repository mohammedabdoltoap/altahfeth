import 'package:flutter/material.dart';

class SouraRangeSelector extends StatelessWidget {
  final String startSectionTitle;
  final String endSectionTitle;
  final String? headerDateText;
  final String fromSouraLabel;
  final String fromAyaLabel;
  final String? fromSouraValue;
  final String? fromAyaValue;

  final List<Map<String, dynamic>> souraItems;
  final Map<String, dynamic>? selectedSoura;
  final ValueChanged<Map<String, dynamic>?> onSouraChanged;

  final int? selectedAya;
  final ValueChanged<int?> onAyaChanged;

  const SouraRangeSelector({
    super.key,
    required this.startSectionTitle,
    required this.endSectionTitle,
    this.headerDateText,
    this.fromSouraLabel = "من سورة",
    this.fromAyaLabel = "من الاية",
    required this.fromSouraValue,
    required this.fromAyaValue,
    required this.souraItems,
    required this.selectedSoura,
    required this.onSouraChanged,
    required this.selectedAya,
    required this.onAyaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ayatCount = int.tryParse(selectedSoura?['ayat_count']?.toString() ?? '0') ?? 0;

    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (headerDateText != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        headerDateText!,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Text(
                  startSectionTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                _ReadOnlyField(
                  icon: Icons.play_arrow,
                  label: fromSouraLabel,
                  value: fromSouraValue,
                ),
                const SizedBox(height: 10),
                _ReadOnlyField(
                  icon: Icons.format_list_numbered,
                  label: fromAyaLabel,
                  value: fromAyaValue,
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endSectionTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.play_arrow, color: theme.colorScheme.primary.withOpacity(0.7)),
                    labelText: "الي سورة",
                  ),
                  value: selectedSoura,
                  items: souraItems.map((soura) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: soura,
                      child: Text(
                        "${soura['soura_name']} (${soura['soura_no']})",
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                  onChanged: onSouraChanged,
                ),
                const SizedBox(height: 10),
                if (selectedSoura != null)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.format_list_numbered, color: theme.colorScheme.primary.withOpacity(0.7)),
                      labelText: "الي الآية رقم",
                    ),
                    value: selectedAya,
                    items: List.generate(
                      ayatCount,
                          (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text((index + 1).toString()),
                      ),
                    ),
                    onChanged: onAyaChanged,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _ReadOnlyField({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      enabled: false,
      initialValue: value ?? '',
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7)),
        labelText: label,
      ),
      style: const TextStyle(fontSize: 18),
    );
  }
}

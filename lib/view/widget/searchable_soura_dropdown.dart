import 'package:flutter/material.dart';

class SearchableSouraDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> souraList;
  final Map<String, dynamic>? selectedSoura;
  final Function(Map<String, dynamic>) onSelected;
  final String labelText;
  final String hintText;
  final Color accentColor;

  const SearchableSouraDropdown({
    Key? key,
    required this.souraList,
    required this.selectedSoura,
    required this.onSelected,
    required this.labelText,
    this.hintText = "ابحث عن سورة...",
    this.accentColor = Colors.teal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return souraList;
        }
        return souraList.where((soura) {
          final souraName = soura['soura_name'].toString().toLowerCase();
          final souraNo = soura['soura_no'].toString();
          final searchText = textEditingValue.text.toLowerCase();
          return souraName.contains(searchText) || souraNo.contains(searchText);
        });
      },
      displayStringForOption: (Map<String, dynamic> option) {
        return "${option['soura_name']} (${option['soura_no']})";
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        if (selectedSoura != null && textEditingController.text.isEmpty) {
          textEditingController.text = "${selectedSoura!['soura_name']} (${selectedSoura!['soura_no']})";
        }
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.menu_book, color: accentColor),
            labelText: labelText,
            labelStyle: TextStyle(color: accentColor),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        );
      },
      onSelected: onSelected,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              elevation: 8.0,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 250,
                  maxWidth: MediaQuery.of(context).size.width - 40,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.menu_book,
                                // color: accentColor.shade700,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${option['soura_name']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${option['soura_no']}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  // color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

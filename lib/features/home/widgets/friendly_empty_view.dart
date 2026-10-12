import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Friendly empty view shown when search yields 0 items or a category has no items.
class FriendlyEmptyView extends StatelessWidget {
  final String searchQuery;
  final String? category;
  final VoidCallback onClearSearch;
  final ValueChanged<String>? onSuggestionTap;

  const FriendlyEmptyView({
    super.key,
    required this.searchQuery,
    this.category,
    required this.onClearSearch,
    this.onSuggestionTap,
  });

  static const List<Map<String, String>> _suggestions = [
    {'label': 'Pizza', 'icon': '🍕'},
    {'label': 'Burger', 'icon': '🍔'},
    {'label': 'Salad', 'icon': '🥗'},
    {'label': 'Pasta', 'icon': '🍜'},
    {'label': 'Cake', 'icon': '🍰'},
    {'label': 'Chicken', 'icon': '🍗'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isSearch = searchQuery.trim().isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friendly Icon Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF7ED),
                border: Border.all(
                  color: const Color(0xFFFFD8A8),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isSearch ? Icons.search_off_rounded : Icons.restaurant_menu_rounded,
                  size: 48,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
            const SizedBox(height: 20.0),

            // Friendly Title
            Text(
              isSearch ? 'No Dishes Found' : 'No Recipes In This Category',
              textAlign: TextAlign.center,
              style: AppTextStyles.screenHeading.copyWith(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8.0),

            // Subtitle
            Text(
              isSearch
                  ? 'We couldn\'t find any meals matching "$searchQuery". Try exploring popular food suggestions below.'
                  : 'There are currently no items in the $category category. Try selecting "All" to browse the full menu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7A6E65),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22.0),

            // Popular Suggestions (if searching)
            if (isSearch && onSuggestionTap != null) ...[
              Text(
                'POPULAR SEARCHES',
                style: GoogleFonts.poppins(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9A3412),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: _suggestions.map((item) {
                  return InkWell(
                    onTap: () => onSuggestionTap!(item['label']!),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 7.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEADBCE),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item['icon']!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            item['label']!,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22.0),
            ],

            // Clear Button
            OutlinedButton.icon(
              onPressed: onClearSearch,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                side: const BorderSide(
                  color: AppColors.primaryOrange,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isSearch ? 'Clear Search' : 'View All Dishes',
                style: GoogleFonts.poppins(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

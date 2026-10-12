import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';

class SupportConciergeSheet extends StatefulWidget {
  const SupportConciergeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SupportConciergeSheet(),
    );
  }

  @override
  State<SupportConciergeSheet> createState() => _SupportConciergeSheetState();
}

class _SupportConciergeSheetState extends State<SupportConciergeSheet> {
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How can I track or modify an active order?',
      'answer':
          'You can view real-time delivery estimates and cooking updates directly from your order summary, or message our live concierge team for instant adjustments.',
    },
    {
      'question': 'What is your refund and cancellation policy?',
      'answer':
          'Our gourmet guarantee ensures a 100% full refund or immediate replacement if any dish fails to meet your expectations or arrives delayed.',
    },
    {
      'question': 'Can I request special dietary customizations?',
      'answer':
          'Yes! Every recipe page outlines detailed allergens and ingredients. You can add specific preparation notes before placing your order.',
    },
  ];

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    UIHelpers.showTimedSnackBar(
      context,
      message: '$label copied to clipboard: $text',
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Color(0xFF4CAF50),
        size: 20,
      ),
      duration: const Duration(seconds: 3),
      progressColor: AppColors.primaryOrange,
    );
  }

  void _openLiveChat() {
    UIHelpers.showTimedSnackBar(
      context,
      message: 'Connecting to VIP Foodie Concierge... Average wait: < 30s',
      icon: const Icon(
        Icons.chat_bubble_outline_rounded,
        color: AppColors.headerYellow,
        size: 20,
      ),
      duration: const Duration(seconds: 3),
      progressColor: AppColors.primaryOrange,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark,
                        size: 16,
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFCCBC)),
                    ),
                    child: const Text(
                      'COMING SOON',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD24B1B),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎧 24/7 VIP CONCIERGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '• COMING SOON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2E7D32,
                          ).withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/support.svg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'Customer Care & Concierge',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenHeading.copyWith(
                  fontSize: 21,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Have a question about your order, delivery time, or need dining assistance? We are here around the clock to ensure you have a seamless experience.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySubtitle.copyWith(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFE65100),
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Direct live concierge chat & toll-free support are launching soon!',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8D4004),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildContactCard(
                icon: Icons.chat_bubble_rounded,
                iconColor: AppColors.primaryOrange,
                iconBg: const Color(0xFFFFF0EB),
                title: 'Live Concierge Chat',
                subtitle: 'Instant replies from culinary experts',
                badgeText: 'Coming Soon',
                badgeColor: AppColors.primaryOrange,
                onTap: _openLiveChat,
              ),
              const SizedBox(height: 10),
              _buildContactCard(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFF1976D2),
                iconBg: const Color(0xFFE3F2FD),
                title: 'Toll-Free Hotline',
                subtitle: '1-800-BICTREE (242-8733)',
                badgeText: 'Coming Soon',
                badgeColor: const Color(0xFF1976D2),
                onTap: () =>
                    _copyToClipboard('1-800-242-8733', 'Hotline Number'),
              ),
              const SizedBox(height: 10),
              _buildContactCard(
                icon: Icons.alternate_email_rounded,
                iconColor: const Color(0xFF8E24AA),
                iconBg: const Color(0xFFF3E5F5),
                title: 'VIP Email Assistance',
                subtitle: 'concierge@bictreefood.com',
                badgeText: 'Coming Soon',
                badgeColor: const Color(0xFF8E24AA),
                onTap: () => _copyToClipboard(
                  'concierge@bictreefood.com',
                  'Email Address',
                ),
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Frequently Asked Questions',
                  style: AppTextStyles.screenHeading.copyWith(fontSize: 15.5),
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(_faqs.length, (index) {
                final faq = _faqs[index];
                final isExpanded = _expandedFaqIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isExpanded
                          ? AppColors.primaryOrange.withValues(alpha: 0.3)
                          : const Color(0xFFEEEEEE),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _expandedFaqIndex = isExpanded ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.help_outline_rounded,
                                size: 18,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Text(
                                faq['answer']!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Close Concierge',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

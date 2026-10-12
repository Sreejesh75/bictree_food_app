import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

class SocialAuthSection extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onBiometricTap;

  const SocialAuthSection({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.onBiometricTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: Color(0xFFEADBCE), thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                AppStrings.orSignUpWith,
                style: AppTextStyles.promptText.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8C7D73),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: Color(0xFFEADBCE), thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 18.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialCircleButton(
              onTap: onGoogleTap,
              tooltip: 'Sign in with Google',
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(painter: _GoogleLogoPainter()),
              ),
            ),
            const SizedBox(width: 20.0),

            _SocialCircleButton(
              onTap: onFacebookTap,
              tooltip: 'Sign in with Facebook',
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF1877F2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'f',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'sans-serif',
                    height: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20.0),

            _SocialCircleButton(
              onTap: onBiometricTap,
              tooltip: 'Biometric / Fingerprint Login',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD9C3), width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 22,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  const _SocialCircleButton({required this.child, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          splashColor: AppColors.primaryOrange.withValues(alpha: 0.12),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEADBCE), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      -0.785,
      1.57,
      false,
      paint,
    );

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      0.785,
      1.57,
      false,
      paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      2.355,
      1.57,
      false,
      paint,
    );

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
      3.925,
      1.57,
      false,
      paint,
    );

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - 2,
          center.dy - (w * 0.11),
          radius + 2,
          w * 0.22,
        ),
        const Radius.circular(2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

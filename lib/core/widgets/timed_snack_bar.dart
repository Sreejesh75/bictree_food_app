import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TimedSnackBarContent extends StatefulWidget {
  final Widget? icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final Color progressColor;
  final TextStyle? textStyle;

  const TimedSnackBarContent({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 3),
    this.progressColor = AppColors.primaryOrange,
    this.textStyle,
  });

  @override
  State<TimedSnackBarContent> createState() => _TimedSnackBarContentState();
}

class _TimedSnackBarContentState extends State<TimedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                widget.message,
                style: widget.textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.actionLabel != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  widget.onAction?.call();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    widget.actionLabel!,
                    style: TextStyle(
                      color: widget.progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _controller.value,
                minHeight: 2.5,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
              );
            },
          ),
        ),
      ],
    );
  }
}

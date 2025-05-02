import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final Map<String, bool> typingUsers;

  const TypingIndicator({
    super.key,
    required this.typingUsers,
  });

  @override
  Widget build(BuildContext context) {
    final activeTypers = typingUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (activeTypers.isEmpty) return const SizedBox();

    String text;
    if (activeTypers.length == 1) {
      text = '${activeTypers[0]} is typing...';
    } else if (activeTypers.length == 2) {
      text = '${activeTypers[0]} and ${activeTypers[1]} are typing...';
    } else {
      text = '${activeTypers.length} people are typing...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Row(
        children: [
          const _TypingDots(),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Interval(
              index * 0.3,
              (index + 1) * 0.3,
              curve: Curves.easeInOut,
            ),
          ),
          child: Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

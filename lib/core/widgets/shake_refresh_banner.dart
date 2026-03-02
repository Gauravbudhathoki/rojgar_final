import 'package:flutter/material.dart';

class ShakeRefreshBanner extends StatefulWidget {
  final bool isRefreshing;
  const ShakeRefreshBanner({super.key, required this.isRefreshing});

  @override
  State<ShakeRefreshBanner> createState() => _ShakeRefreshBannerState();
}

class _ShakeRefreshBannerState extends State<ShakeRefreshBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ShakeRefreshBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !oldWidget.isRefreshing) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isRefreshing
                ? [const Color(0xFF7C3AED), const Color(0xFF2563EB)]
                : [const Color(0xFF1E293B), const Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (widget.isRefreshing
                      ? const Color(0xFF7C3AED)
                      : Colors.black)
                  .withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.isRefreshing
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          key: ValueKey('shake'),
                          Icons.vibration,
                          color: Colors.white70,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    widget.isRefreshing
                        ? 'Refreshing jobs...'
                        : 'Shake to refresh jobs 📳',
                    key: ValueKey(widget.isRefreshing),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}